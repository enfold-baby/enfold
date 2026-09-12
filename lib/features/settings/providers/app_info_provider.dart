import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPackageInfo {
  const AppPackageInfo({
    required this.version,
    required this.buildNumber,
    required this.appName,
  });

  final String version;
  final String buildNumber;
  final String appName;

  String get versionLabel => 'v$version ($buildNumber)';
}

final appPackageInfoProvider = FutureProvider<AppPackageInfo>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppPackageInfo(
    version: info.version,
    buildNumber: info.buildNumber,
    appName: info.appName,
  );
});