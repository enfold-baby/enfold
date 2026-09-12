import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/app_info_provider.dart';

class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final infoAsync = ref.watch(appPackageInfoProvider);

    return infoAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (info) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              info.appName,
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              key: const Key('about_version'),
              info.versionLabel,
              style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
            ),
            const SizedBox(height: 8),
            Text(
              'Grow with confidence. · Enfold.baby',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.mutedText(brightness),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enfold provides general educational information. It does not replace '
              'professional medical advice, diagnosis, or treatment. In an emergency, '
              'call your local emergency number.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.mutedText(brightness),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}