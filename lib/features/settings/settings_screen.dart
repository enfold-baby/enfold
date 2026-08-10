import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'providers/theme_providers.dart';
import 'widgets/about_section.dart';
import 'widgets/account_section.dart';
import 'widgets/baby_profile_section.dart';
import 'widgets/caregiver_profile_section.dart';
import 'widgets/export_section.dart';
import 'widgets/partner_notifications_section.dart';
import 'widgets/partner_section.dart';
import 'widgets/units_section.dart';
import '../../widgets/sync_refresh.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
          const Divider(height: 32),
          const BabyProfileSection(),
          const Divider(height: 32),
          const ExportSection(),
          const Divider(height: 32),
          const UnitsSection(),
          const Divider(height: 32),
          ListTile(
            title: Text(
              'Appearance',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Parents log at night — dark mode matters.',
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              key: const Key('theme_mode_selector'),
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
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
          const AboutSection(),
        ],
      ),
      ),
    );
  }
}