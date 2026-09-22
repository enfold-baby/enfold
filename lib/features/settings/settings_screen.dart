import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'providers/theme_providers.dart';
import 'widgets/about_section.dart';
import 'widgets/awake_time_section.dart';
import 'widgets/care_reminders_section.dart';
import 'widgets/account_section.dart';
import 'widgets/baby_profile_section.dart';
import 'widgets/caregiver_profile_section.dart';
import 'widgets/export_section.dart';
import 'widgets/language_section.dart';
import 'widgets/legal_section.dart';
import 'widgets/partner_notifications_section.dart';
import 'widgets/partner_section.dart';
import 'widgets/time_format_section.dart';
import 'widgets/units_section.dart';
import '../../widgets/sync_refresh.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SyncRefresh(
        indicatorKey: const Key('settings_pull_to_refresh'),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const AccountSection(),
          const Divider(height: 32),
          const CaregiverProfileSection(),
          const Divider(height: 32),
          const PartnerSection(),
          const PartnerNotificationsSection(),
          const CareRemindersSection(),
          const Divider(height: 32),
          const BabyProfileSection(),
          const Divider(height: 32),
          ListTile(
            key: const Key('settings_pregnancy'),
            leading: const Icon(Icons.favorite_outline),
            title: Text(
              l10n.settingsPregnancyTitle,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              l10n.settingsPregnancySubtitle,
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.pregnancy),
          ),
          const Divider(height: 32),
          const ExportSection(),
          const Divider(height: 32),
          const UnitsSection(),
          const Divider(height: 32),
          const TimeFormatSection(),
          const Divider(height: 32),
          const AwakeTimeSection(),
          const Divider(height: 32),
          const LanguageSection(),
          const Divider(height: 32),
          ListTile(
            title: Text(
              l10n.settingsAppearanceTitle,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              l10n.settingsAppearanceSubtitle,
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              key: const Key('theme_mode_selector'),
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.settingsThemeSystem),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.settingsThemeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.settingsThemeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(selection.first);
              },
            ),
          ),
          const Divider(height: 32),
          const LegalSection(),
          const Divider(height: 32),
          const AboutSection(),
        ],
      ),
      ),
    );
  }
}