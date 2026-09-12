import 'package:enfold/features/settings/providers/app_info_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppPackageInfo formats version label', () {
    const info = AppPackageInfo(
      version: '0.1.0',
      buildNumber: '1',
      appName: 'Enfold',
    );
    expect(info.versionLabel, 'v0.1.0 (1)');
    expect(info.appName, 'Enfold');
  });
}
