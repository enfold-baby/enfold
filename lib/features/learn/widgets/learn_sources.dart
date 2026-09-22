import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/learn_card.dart';

/// "Sources" block at the end of a learn card: one tappable row per citation,
/// opened in the system browser. Kept visually quiet but easy to find, which
/// is what App Review asks for on medical content (guideline 1.4.1).
class LearnSources extends StatelessWidget {
  const LearnSources({super.key, required this.sources});

  final List<LearnSource> sources;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final ink = AppColors.readableInk(AppColors.sleepBlue, brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              AppL10n.of(context).learnSourcesTitle,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          AppL10n.of(context).learnSourcesSubtitle,
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: AppColors.mutedText(brightness),
          ),
        ),
        const SizedBox(height: 6),
        for (final source in sources)
          InkWell(
            key: Key('learn_source_${source.url.hashCode}'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => launchUrl(
              Uri.parse(source.url),
              mode: LaunchMode.externalApplication,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.open_in_new, size: 16, color: ink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          source.title,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: isDark ? AppColors.cream : AppColors.bark,
                          ),
                        ),
                        Text(
                          Uri.parse(source.url).host.replaceFirst('www.', ''),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.mutedText(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
