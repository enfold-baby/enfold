import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Legal',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'How we handle your family’s data.',
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        ListTile(
          key: const Key('settings_privacy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(
            'Privacy policy',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => _open(_privacy),
        ),
        ListTile(
          key: const Key('settings_terms'),
          leading: const Icon(Icons.description_outlined),
          title: Text(
            'Terms of use',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => _open(_terms),
        ),
      ],
    );
  }
}
