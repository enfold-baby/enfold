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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: color,
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
                      color: AppColors.barkSoft,
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