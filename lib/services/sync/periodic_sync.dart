import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'sync_providers.dart';

/// Quiet partner sync while the app is in the foreground.
///
/// Does not show snackbars (pull-to-refresh / manual sync still do).
/// Own the lifecycle from [AppShell] (start in init, [dispose] on shell dispose)
/// so widget tests do not leak timers.
class PeriodicSyncController with WidgetsBindingObserver {
  PeriodicSyncController(this._ref);

  final WidgetRef _ref;
  Timer? _timer;
  bool _running = false;
  bool _started = false;

  static const interval = Duration(seconds: 45);

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _schedule(fireSoon: false);
  }

  void dispose() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _schedule(fireSoon: true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _schedule({bool fireSoon = false}) {
    _timer?.cancel();
    if (fireSoon) {
      unawaited(_tick());
    }
    _timer = Timer.periodic(interval, (_) => unawaited(_tick()));
  }

  Future<void> _tick() async {
    if (_running) return;
    final session = _ref.read(authSessionProvider).valueOrNull;
    if (session == null) return;

    _running = true;
    try {
      await _ref.read(syncActionsProvider).syncIfSignedIn();
    } catch (error, stack) {
      // Background sync stays quiet: a flaky network or a widget that went
      // away mid-sync must not surface as an unhandled async error. The next
      // tick or a pull-to-refresh retries.
      debugPrint('Periodic sync failed: $error\n$stack');
    } finally {
      _running = false;
    }
  }
}
