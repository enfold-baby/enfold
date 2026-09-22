import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/database/database_provider.dart';

/// The languages the UI ships in. English is the fallback for every other
/// device language; learn cards stay English until a clinician reviews a
/// medical translation.
const supportedLocales = [Locale('en'), Locale('ro')];

/// The forced UI language, or null when the app follows the device.
final localeOverrideProvider =
    AsyncNotifierProvider<LocaleOverrideNotifier, Locale?>(
  LocaleOverrideNotifier.new,
);

class LocaleOverrideNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final tag = await ref.read(databaseProvider).settingsDao.languageTag();
    return parseLanguageTag(tag);
  }

  /// Pass null to follow the device language again.
  Future<void> setLocale(Locale? locale) async {
    state = AsyncData(locale);
    await ref
        .read(databaseProvider)
        .settingsDao
        .setLanguageTag(locale?.languageCode);
  }

  /// Anything we do not ship falls back to the device language.
  static Locale? parseLanguageTag(String? tag) {
    if (tag == null) return null;
    for (final locale in supportedLocales) {
      if (locale.languageCode == tag) return locale;
    }
    return null;
  }
}

/// Strings outside the widget tree. Local notifications are scheduled from
/// providers, with no BuildContext to read [AppL10n] from, so they resolve the
/// same locale the UI would show: the Settings override, else the device
/// language, else English.
final appL10nProvider = FutureProvider<AppL10n>((ref) async {
  final override = await ref.watch(localeOverrideProvider.future);
  return lookupAppL10n(override ?? resolvedDeviceLocale());
});

/// The shipped locale closest to the device language, English otherwise.
Locale resolvedDeviceLocale() {
  final device = PlatformDispatcher.instance.locale;
  for (final locale in supportedLocales) {
    if (locale.languageCode == device.languageCode) return locale;
  }
  return supportedLocales.first;
}
