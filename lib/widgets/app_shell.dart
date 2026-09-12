import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/pregnancy/providers/pregnancy_providers.dart';
import '../services/sync/periodic_sync.dart';
import 'quick_add_sheet.dart';
import '../core/datetime/calendar_day.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Docked + lives on tab homes (and Learn articles). Nested log lists and
  /// growth already have their own add button.
  static bool showDockedQuickAdd(String location) {
    const roots = {'/', '/logs', '/learn', '/settings'};
    if (roots.contains(location)) return true;
    return location.startsWith('/learn/');
  }

  static const _tabs = [
    (icon: Icons.today_outlined, selectedIcon: Icons.today, label: 'Today'),
    (
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      label: 'Logs',
    ),
    (icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Learn'),
    (
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  PeriodicSyncController? _periodicSync;
  CalendarDayTicker? _dayTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Keep partner logs warm while the app is open (pauses in background).
      _periodicSync = PeriodicSyncController(ref)..start();
      _dayTicker = CalendarDayTicker(ref)..start();
    });
  }

  @override
  void dispose() {
    _periodicSync?.dispose();
    _dayTicker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final location = router.state.matchedLocation;
        return _buildScaffold(location);
      },
    );
  }

  Widget _buildScaffold(String location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shell = widget.navigationShell;
    final expecting = ref.watch(isExpectingProvider);
    final barColor = isDark ? AppColors.nightElevated : AppColors.creamDeep;
    final showAdd = AppShell.showDockedQuickAdd(location);

    return Scaffold(
      extendBody: false,
      body: shell,
      floatingActionButton: showAdd
          ? FloatingActionButton(
              key: const Key('quick_add_fab'),
              tooltip: 'Add',
              backgroundColor: isDark ? AppColors.sageDeep : AppColors.sage,
              foregroundColor: AppColors.cream,
              onPressed: () =>
                  showQuickAddSheet(context, expecting: expecting),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      floatingActionButtonLocation: showAdd
          ? FloatingActionButtonLocation.centerDocked
          : null,
      bottomNavigationBar: BottomAppBar(
        color: barColor,
        shape: showAdd ? const CircularNotchedRectangle() : null,
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          children: [
            for (var i = 0; i < 2; i++)
              Expanded(
                child: _NavItem(
                  icon: AppShell._tabs[i].icon,
                  selectedIcon: AppShell._tabs[i].selectedIcon,
                  label: AppShell._tabs[i].label,
                  isSelected: shell.currentIndex == i,
                  isDark: isDark,
                  onTap: () => shell.goBranch(i, initialLocation: true),
                ),
              ),
            if (showAdd) const SizedBox(width: 56),
            for (var i = 2; i < 4; i++)
              Expanded(
                child: _NavItem(
                  icon: AppShell._tabs[i].icon,
                  selectedIcon: AppShell._tabs[i].selectedIcon,
                  label: AppShell._tabs[i].label,
                  isSelected: shell.currentIndex == i,
                  isDark: isDark,
                  onTap: () => shell.goBranch(i, initialLocation: true),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? (isDark ? AppColors.nightAccent : AppColors.sageDeep)
        : AppColors.navUnselected(isDark ? Brightness.dark : Brightness.light);

    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? selectedIcon : icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
