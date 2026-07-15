import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/auth/auth_providers.dart';
import '../../partner/providers/partner_providers.dart';

class PartnerNotificationsSection extends ConsumerWidget {
  const PartnerNotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final session = ref.watch(authSessionProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();

    final activityPush = ref.watch(partnerActivityPushProvider).valueOrNull;
    final gentleNudge = ref.watch(partnerGentleNudgeProvider).valueOrNull;
    final actions = ref.read(partnerNotificationActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            'Partner notifications',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            'Optional awareness — off by default, no guilt copy.',
            style: GoogleFonts.nunito(color: AppColors.mutedText(brightness)),
          ),
        ),
        SwitchListTile(
          key: const Key('partner_activity_push_toggle'),
          title: Text(
            'When partner logs',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Push when your co-parent adds a feed, diaper, or sleep entry.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.mutedText(brightness),
            ),
          ),
          value: activityPush ?? false,
          onChanged: (value) => actions.setActivityPushEnabled(value),
        ),
        SwitchListTile(
          key: const Key('partner_gentle_nudge_toggle'),
          title: Text(
            'Gentle reminders',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Soft in-app nudge if a core log has not been recorded in a while.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.mutedText(brightness),
            ),
          ),
          value: gentleNudge ?? false,
          onChanged: (value) => actions.setGentleNudgeEnabled(value),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Activity pushes need Firebase on this device — we will register '
            'automatically once FCM is configured.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.mutedText(brightness),
            ),
          ),
        ),
      ],
    );
  }
}