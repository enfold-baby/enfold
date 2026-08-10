import 'package:bloomdue_baby/core/config/api_config.dart';
import 'package:bloomdue_baby/services/update/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppUpdateInfo holds remote metadata', () {
    const info = AppUpdateInfo(
      version: '0.1.1',
      buildNumber: 12,
      downloadUrl: 'http://example/apk',
      forceUpdate: true,
    );
    expect(info.version, '0.1.1');
    expect(info.buildNumber, 12);
    expect(info.forceUpdate, isTrue);
  });

  test('ApiConfig exposes a non-empty baseUrl', () {
    expect(ApiConfig.baseUrl, isNotEmpty);
  });
}
