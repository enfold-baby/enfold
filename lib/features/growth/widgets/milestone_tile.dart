import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/milestone_definition.dart';

class MilestoneTile extends StatelessWidget {
  const MilestoneTile({
    super.key,
    required this.status,
    required this.onToggle,
  });

  final MilestoneStatus status;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final achieved = status.isAchieved;
    final dateFormat = DateFormat.yMMMd();
    final l10n = AppL10n.of(context);

    return CheckboxListTile(
      key: Key('milestone_${status.definition.key}'),
      value: achieved,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      activeColor: AppColors.sage,
      title: Text(
        status.definition.title(l10n),
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          decoration: achieved ? null : null,
        ),
      ),
      subtitle: Text(
        achieved && status.achievedAt != null
            ? l10n.milestoneCelebrated(
                dateFormat.format(status.achievedAt!),
                status.definition.ageHint(l10n),
              )
            : status.definition.ageHint(l10n),
        style: GoogleFonts.nunito(fontSize: 13, color: AppColors.mutedText(Theme.of(context).brightness)),
      ),
    );
  }
}