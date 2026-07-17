import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const _nunito = 'Nunito';
  static const _fraunces = 'Fraunces';

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.nightAccent : AppColors.sage,
      onPrimary: isDark ? AppColors.night : AppColors.cream,
      primaryContainer: isDark
          ? AppColors.sageDeep
          : AppColors.sage.withValues(alpha: 0.15),
      onPrimaryContainer: isDark ? AppColors.cream : AppColors.sageDeep,
      secondary: AppColors.bloom,
      onSecondary: AppColors.cream,
      surface: isDark ? AppColors.night : AppColors.cream,
      onSurface: isDark ? AppColors.cream : AppColors.bark,
      onSurfaceVariant: AppColors.mutedText(brightness),
      surfaceContainerHighest: isDark
          ? AppColors.nightCard
          : AppColors.creamDeep,
      outline: isDark
          ? AppColors.nightLine
          : AppColors.bark.withValues(alpha: 0.2),
      outlineVariant: isDark
          ? AppColors.nightLine.withValues(alpha: 0.85)
          : AppColors.bark.withValues(alpha: 0.12),
      error: AppColors.bloomDeep,
      onError: AppColors.cream,
    );

    final baseText = ThemeData(
      brightness: brightness,
    ).textTheme.apply(fontFamily: _nunito);
    final textTheme = baseText.copyWith(
      displayLarge: const TextStyle(
        fontFamily: _fraunces,
        fontSize: 42,
        height: 1.05,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: const TextStyle(
        fontFamily: _fraunces,
        fontSize: 34,
        height: 1.1,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: const TextStyle(
        fontFamily: _fraunces,
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: const TextStyle(
        fontFamily: _fraunces,
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: const TextStyle(
        fontFamily: _nunito,
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: const TextStyle(
        fontFamily: _nunito,
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: const TextStyle(
        fontFamily: _nunito,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: const TextStyle(
        fontFamily: _nunito,
        fontSize: 14,
        height: 1.45,
      ),
      labelLarge: const TextStyle(
        fontFamily: _nunito,
        fontWeight: FontWeight.w800,
      ),
    );

    final segmentedStyle = SegmentedButton.styleFrom(
      backgroundColor: isDark ? AppColors.nightCard : AppColors.creamDeep,
      foregroundColor: AppColors.mutedText(brightness),
      selectedBackgroundColor: isDark
          ? AppColors.sageDeep
          : AppColors.sage.withValues(alpha: 0.22),
      selectedForegroundColor: isDark ? AppColors.cream : AppColors.sageDeep,
      side: BorderSide(
        color: isDark
            ? AppColors.nightLine
            : AppColors.bark.withValues(alpha: 0.15),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fraunces,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? AppColors.nightAccent : AppColors.sage,
        textColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: _nunito,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: _nunito,
          fontSize: 14,
          height: 1.4,
          color: AppColors.mutedText(brightness),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.nightCard : Colors.white,
        labelStyle: TextStyle(
          fontFamily: _nunito,
          color: isDark ? AppColors.cream : AppColors.bark,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          fontFamily: _nunito,
          color: AppColors.mutedText(brightness),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? AppColors.nightAccent : AppColors.sage,
            width: 2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.sageDeep : AppColors.sage,
              foregroundColor: AppColors.cream,
              disabledBackgroundColor: isDark
                  ? AppColors.nightDisabledFill
                  : AppColors.sage.withValues(alpha: 0.35),
              disabledForegroundColor: isDark
                  ? AppColors.nightDisabledLabel
                  : AppColors.cream.withValues(alpha: 0.7),
              minimumSize: const Size(0, 48),
              textStyle: const TextStyle(
                fontFamily: _nunito,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ).copyWith(
              side: WidgetStateProperty.resolveWith((states) {
                if (!isDark || !states.contains(WidgetState.disabled)) {
                  return BorderSide.none;
                }
                return const BorderSide(color: AppColors.nightLine);
              }),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? AppColors.cream : AppColors.sageDeep,
          side: BorderSide(
            color: isDark
                ? AppColors.nightLine
                : AppColors.sage.withValues(alpha: 0.5),
          ),
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(
            fontFamily: _nunito,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.nightAccent : AppColors.sageDeep,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.cream;
          }
          return isDark ? AppColors.nightMuted : AppColors.creamDeep;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? AppColors.sage
                : AppColors.sage.withValues(alpha: 0.65);
          }
          return isDark
              ? AppColors.nightLine
              : AppColors.bark.withValues(alpha: 0.25);
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(style: segmentedStyle),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardSurface(brightness),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: isDark ? 12 : 0,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? AppColors.nightElevated : AppColors.creamDeep,
        indicatorColor: isDark
            ? AppColors.sageDeep
            : AppColors.sage.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _nunito,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? (isDark ? AppColors.cream : AppColors.sageDeep)
                : AppColors.navUnselected(brightness),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? (isDark ? AppColors.cream : AppColors.sageDeep)
                : AppColors.navUnselected(brightness),
            size: selected ? 26 : 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.nightCard : AppColors.bark,
        contentTextStyle: const TextStyle(
          fontFamily: _nunito,
          color: AppColors.cream,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerColor: colorScheme.outlineVariant,
    );
  }
}
