import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/config/api_config.dart';

const _installerChannel = MethodChannel('baby.bloomdue.app/installer');

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.forceUpdate,
  });

  final String version;
  final int buildNumber;
  final String downloadUrl;
  final bool forceUpdate;
}

class UpdateService {
  UpdateService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
  }

  /// Returns update info when remote build_number is higher than local.
  /// Android-only for install path; other platforms return null (no crash).
  Future<AppUpdateInfo?> checkForUpdate() async {
    if (kIsWeb) return null;
    // APK install only applies to Android sideload builds.
    if (defaultTargetPlatform != TargetPlatform.android) return null;

    try {
      final response = await _http
          .get(Uri.parse('${ApiConfig.baseUrl}/v1/app-version'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final remoteBuild = (data['build_number'] as num?)?.toInt() ?? 0;

      if (remoteBuild <= currentBuild) return null;

      return AppUpdateInfo(
        version: data['version'] as String? ?? 'new',
        buildNumber: remoteBuild,
        downloadUrl: _resolveUrl(
          data['download_url'] as String? ?? '/v1/app-version/download',
        ),
        forceUpdate: data['force_update'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK then opens the system package installer.
  Future<void> downloadAndInstall(
    String url, {
    required void Function(double progress) onProgress,
  }) async {
    final cacheDir = await getTemporaryDirectory();
    final savePath = '${cacheDir.path}/bloomdue-baby.apk';
    final old = File(savePath);
    if (old.existsSync()) old.deleteSync();

    final request = http.Request('GET', Uri.parse(url));
    final streamed = await _http.send(request);
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Download failed (${streamed.statusCode})');
    }

    final total = streamed.contentLength ?? 0;
    final sink = File(savePath).openWrite();
    var received = 0;
    await for (final chunk in streamed.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) onProgress(received / total);
    }
    await sink.close();
    onProgress(1);

    await _installerChannel.invokeMethod<void>('installApk', {'path': savePath});
  }
}
