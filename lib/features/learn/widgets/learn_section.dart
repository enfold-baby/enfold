import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class LearnSection extends StatelessWidget {
  const LearnSection({
    super.key,
    required this.label,
    required this.color,
    this.body,
    this.bullets,
  });

  final String label;
  final Color color;
  final String? body;
  final List<String>? bullets;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = AppColors.readableInk(color, Theme.of(context).brightness);

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
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (body != null)
          Text(
            body!,
            style: GoogleFonts.nunito(
              fontSize: 15,
              height: 1.55,
              color: isDark ? AppColors.cream : AppColors.bark,
            ),
          ),
        if (bullets != null)
          ...bullets!.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: AppColors.mutedText(Theme.of(context).brightness),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        height: 1.45,
                        color: isDark ? AppColors.cream : AppColors.bark,
                      ),
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