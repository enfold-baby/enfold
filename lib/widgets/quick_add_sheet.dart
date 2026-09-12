import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../features/today/models/log_type.dart';

Future<void> showQuickAddSheet(
  BuildContext context, {
  required bool expecting,
}) {
  final items = <_QuickAddItem>[
    for (final type in LogType.values)
      _QuickAddItem(
        label: type.label,
        icon: type.icon,
        color: type.color,
        path: AppRoutes.logForm(type),
      ),
    const _QuickAddItem(
      label: 'Growth',
      icon: Icons.monitor_weight_outlined,
      color: AppColors.sage,
      path: AppRoutes.logsGrowthAdd,
    ),
    if (expecting)
      const _QuickAddItem(
        label: 'Pregnancy',
        icon: Icons.favorite_outline,
        color: AppColors.bloom,
        path: AppRoutes.pregnancy,
      ),
  ];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final bottomInset = MediaQuery.paddingOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottomInset + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a log',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in items)
                ListTile(
                  key: Key('quick_add_${item.label.toLowerCase()}'),
                  leading: CircleAvatar(
                    backgroundColor: item.color,
                    foregroundColor: AppColors.cream,
                    child: Icon(item.icon, size: 20),
                  ),
                  title: Text(
                    item.label,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(item.path);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuickAddItem {
  const _QuickAddItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.path,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String path;
}
