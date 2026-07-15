import 'package:bloomdue_baby/features/settings/providers/app_info_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppPackageInfo formats version label and detects beta', () {
    const info = AppPackageInfo(
      version: '0.1.0',
      buildNumber: '1',
      appName: 'BloomDue',
    );
    expect(info.versionLabel, 'v0.1.0 (1)');
    expect(info.isBeta, isTrue);
  });

  test('AppPackageInfo treats 1.x as non-beta', () {
    const info = AppPackageInfo(
      version: '1.0.0',
      buildNumber: '12',
      appName: 'BloomDue',
    );
    expect(info.isBeta, isFalse);
  });
}