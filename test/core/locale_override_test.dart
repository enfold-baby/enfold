import 'package:enfold/features/settings/providers/locale_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('supportedLocales', () {
    test('ships English and Romanian, English first as the fallback', () {
      expect(supportedLocales.first, const Locale('en'));
      expect(supportedLocales, contains(const Locale('ro')));
    });
  });

  group('LocaleOverrideNotifier.parseLanguageTag', () {
    test('null keeps the device language', () {
      expect(LocaleOverrideNotifier.parseLanguageTag(null), isNull);
    });

    test('a tag we ship becomes that locale', () {
      expect(
        LocaleOverrideNotifier.parseLanguageTag('ro'),
        const Locale('ro'),
      );
      expect(
        LocaleOverrideNotifier.parseLanguageTag('en'),
        const Locale('en'),
      );
    });

    test('a tag we do not ship falls back to the device language', () {
      expect(LocaleOverrideNotifier.parseLanguageTag('hu'), isNull);
      expect(LocaleOverrideNotifier.parseLanguageTag(''), isNull);
    });
  });
}
