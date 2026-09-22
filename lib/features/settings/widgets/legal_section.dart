import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  static final _privacy = Uri.parse('https://enfold.baby/privacy/');
  static final _terms = Uri.parse('https://enfold.baby/terms/');

  Future<void> _open(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final l10n = AppL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            l10n.settingsLegalTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            l10n.settingsLegalSubtitle,
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        ListTile(
          key: const Key('settings_privacy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(
            l10n.settingsPrivacyPolicy,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => _open(_privacy),
        ),
        ListTile(
          key: const Key('settings_terms'),
          leading: const Icon(Icons.description_outlined),
          title: Text(
            l10n.settingsTermsOfUse,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => _open(_terms),
        ),
      ],
    );
  }
}
