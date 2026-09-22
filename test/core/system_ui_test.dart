import 'package:enfold/core/theme/system_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemUi.overlayStyle', () {
    test('light theme: transparent bars, dark icons', () {
      final style = SystemUi.overlayStyle(Brightness.light);
      expect(style.statusBarColor, Colors.transparent);
      expect(style.systemNavigationBarColor, Colors.transparent);
      expect(style.systemNavigationBarDividerColor, Colors.transparent);
      expect(style.statusBarIconBrightness, Brightness.dark);
      expect(style.systemNavigationBarIconBrightness, Brightness.dark);
      expect(style.statusBarBrightness, Brightness.light);
    });

    test('dark theme: transparent bars, light icons', () {
      final style = SystemUi.overlayStyle(Brightness.dark);
      expect(style.statusBarColor, Colors.transparent);
      expect(style.systemNavigationBarColor, Colors.transparent);
      expect(style.statusBarIconBrightness, Brightness.light);
      expect(style.systemNavigationBarIconBrightness, Brightness.light);
      expect(style.statusBarBrightness, Brightness.dark);
    });

    test('keeps contrast enforcement so 3-button navigation stays readable',
        () {
      for (final brightness in Brightness.values) {
        expect(
          SystemUi.overlayStyle(brightness).systemNavigationBarContrastEnforced,
          isTrue,
        );
      }
    });
  });

  test('enableEdgeToEdge asks the platform for edge-to-edge', () async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    SystemUi.enableEdgeToEdge();
    await Future<void>.delayed(Duration.zero);

    final call = calls.singleWhere(
      (c) => c.method == 'SystemChrome.setEnabledSystemUIMode',
    );
    expect(call.arguments, 'SystemUiMode.edgeToEdge');
  });
}
