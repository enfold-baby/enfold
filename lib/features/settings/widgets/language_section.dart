import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/locale_providers.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final brightness = Theme.of(context).brightness;
    final override = ref.watch(localeOverrideProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(
            l10n.settingsLanguageTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            l10n.settingsLanguageSubtitle,
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<String>(
            key: const Key('language_selector'),
            segments: [
              ButtonSegment(
                value: 'system',
                label: Text(l10n.settingsLanguageSystem),
                icon: const Icon(Icons.smartphone),
              ),
              ButtonSegment(
                value: 'en',
                label: Text(l10n.settingsLanguageEnglish),
              ),
              ButtonSegment(
                value: 'ro',
                label: Text(l10n.settingsLanguageRomanian),
              ),
            ],
            selected: {override?.languageCode ?? 'system'},
            onSelectionChanged: (selection) {
              final choice = selection.first;
              ref.read(localeOverrideProvider.notifier).setLocale(
                    choice == 'system' ? null : Locale(choice),
                  );
            },
          ),
        ),
      ],
    );
  }
}
