import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows [items] one page at a time inside a parent scroll view.
///
/// The next page loads automatically when the parent scrolls near the bottom
/// (via the nearest [ScrollNotificationObserver], which [Scaffold] provides)
/// and a "Load more" button stays as a visible fallback.
class PaginatedColumn<T> extends ConsumerStatefulWidget {
  const PaginatedColumn({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.pageSize = 10,
    this.visibleCountProvider,
    this.loadMoreKey,
    this.autoLoadThreshold = 320,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final int pageSize;

  /// Optional shared counter so the page position survives rebuilds of the
  /// parent screen (the hub uses one). Otherwise local state is used.
  final StateProvider<int>? visibleCountProvider;
  final Key? loadMoreKey;

  /// Pixels from the bottom of the parent scroll view at which the next page
  /// loads on its own.
  final double autoLoadThreshold;

  @override
  ConsumerState<PaginatedColumn<T>> createState() =>
      _PaginatedColumnState<T>();
}

class _PaginatedColumnState<T> extends ConsumerState<PaginatedColumn<T>> {
  late int _localVisible;
  ScrollNotificationObserverState? _observer;
  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
    _localVisible = widget.pageSize;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ScrollNotificationObserver.maybeOf(context);
    if (!identical(observer, _observer)) {
      _observer?.removeListener(_onScroll);
      _observer = observer;
      _observer?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  int get _visibleCount {
    final provider = widget.visibleCountProvider;
    if (provider != null) return ref.watch(provider);
    return _localVisible;
  }

  int _readVisibleCount() {
    final provider = widget.visibleCountProvider;
    if (provider != null) return ref.read(provider);
    return _localVisible;
  }

  bool get _hasMore => widget.items.length > _readVisibleCount();

  void _loadMore() {
    if (!_hasMore) return;
    final provider = widget.visibleCountProvider;
    if (provider != null) {
      ref.read(provider.notifier).state += widget.pageSize;
      return;
    }
    setState(() => _localVisible += widget.pageSize);
  }

  void _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return;
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return;
    }
    if (!_hasMore || _loadScheduled) return;
    if (notification.metrics.extentAfter > widget.autoLoadThreshold) return;
    _loadScheduled = true;
    // Never mutate state during a scroll callback; wait for the frame to end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (mounted) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.items.take(_visibleCount).toList();
    final remaining = widget.items.length - shown.length;
    return Column(
      children: [
        for (final item in shown) widget.itemBuilder(context, item),
        if (remaining > 0) ...[
          const SizedBox(height: 4),
          OutlinedButton(
            key: widget.loadMoreKey,
            onPressed: _loadMore,
            child: Text('Load more ($remaining remaining)'),
          ),
        ],
      ],
    );
  }
}
