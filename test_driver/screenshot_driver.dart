import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      final dir = Directory('screenshots/x_post');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('${dir.path}/$screenshotName.png');
      file.writeAsBytesSync(screenshotBytes);
      // ignore: avoid_print
      print('Wrote ${file.path} (${screenshotBytes.length} bytes)');
      return true;
    },
  );
}
