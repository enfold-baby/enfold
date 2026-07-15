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
            if (info.isBeta) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bloom.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  key: const Key('about_beta_badge'),
                  'Private beta',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bloomDeep,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Grow with confidence. · bloomdue.baby',
              style: GoogleFonts.nunito(
                fontSize: 14,
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