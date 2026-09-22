import 'package:enfold/features/settings/providers/locale_providers.dart';
import 'package:enfold/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

const _delegates = <LocalizationsDelegate<Object>>[
  AppL10n.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Widgets read their strings from [AppL10n], so every pumped app needs the
/// delegates. Defaults to English, the language the assertions are written in.
MaterialApp localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: supportedLocales,
    localizationsDelegates: _delegates,
    home: home,
  );
}

MaterialApp localizedRouterApp(
  GoRouter router, {
  Locale locale = const Locale('en'),
}) {
  return MaterialApp.router(
    locale: locale,
    supportedLocales: supportedLocales,
    localizationsDelegates: _delegates,
    routerConfig: router,
  );
}
