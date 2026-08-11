import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../services/sync/periodic_sync.dart';
import '../services/update/update_service.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.today_outlined, selectedIcon: Icons.today, label: 'Today'),
    (
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      label: 'Logs',
    ),
    (icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Learn'),
    (
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Pregnancy',
    ),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _updateChecked = false;
  final _updateService = UpdateService();
  PeriodicSyncController? _periodicSync;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkForUpdate();
      // Keep partner logs warm while the app is open (pauses in background).
      _periodicSync = PeriodicSyncController(ref)..start();
    });
  }

  @override
  void dispose() {
    _periodicSync?.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    if (_updateChecked) return;
    _updateChecked = true;

    final update = await _updateService.checkForUpdate();
    if (update != null && mounted) {
      _showUpdateDialog(update);
    }
  }

  void _showUpdateDialog(AppUpdateInfo update) {
    showDialog<void>(
      context: context,
      barrierDismissible: !update.forceUpdate,
      builder: (ctx) => AlertDialog(
        title: const Text('Update available'),
        content: Text(
          'A new BloomDue version (${update.version}, build ${update.buildNumber}) '
          'is ready. You can update now or later.',
        ),
        actions: [
          if (!update.forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Later'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _downloadAndInstall(update);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _downloadAndInstall(AppUpdateInfo update) {
    final progress = ValueNotifier<double>(0);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Downloading update…'),
          content: ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (_, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: value <= 0 ? null : value),
                const SizedBox(height: 12),
                Text(
                  value <= 0 ? 'Starting…' : '${(value * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _updateService
        .downloadAndInstall(
          update.downloadUrl,
          onProgress: (p) => progress.value = p,
        )
        .then((_) {
          if (mounted) Navigator.of(context).pop();
        })
        .catchError((Object _) {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not download the update. Try again later.'),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shell = widget.navigationShell;

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightElevated : AppColors.creamDeep,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.nightLine
                  : AppColors.bark.withValues(alpha: 0.1),
            ),
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ]
              : null,
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranch,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in AppShell._destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }
}
