import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';

/// Shows [items] one page at a time inside a parent scroll view.
///
/// Loading is explicit: a page appears only when the parent taps "Load more".
/// An earlier version also loaded on scroll, but a single fling fired the
/// listener several times and swallowed three or four pages at once, so the
/// button was never seen and anything placed after this list (Recently
/// deleted, on the Logs hub) kept being pushed out of reach.
class PaginatedColumn<T> extends ConsumerStatefulWidget {
  const PaginatedColumn({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.pageSize = 10,
    this.visibleCountProvider,
    this.loadMoreKey,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final int pageSize;

  /// Optional shared counter so the page position survives rebuilds of the
  /// parent screen (the hub uses one). Otherwise local state is used.
  final StateProvider<int>? visibleCountProvider;
  final Key? loadMoreKey;

  @override
  ConsumerState<PaginatedColumn<T>> createState() => _PaginatedColumnState<T>();
}

class _PaginatedColumnState<T> extends ConsumerState<PaginatedColumn<T>> {
  late int _localVisible;

  @override
  void initState() {
    super.initState();
    _localVisible = widget.pageSize;
  }

  int get _visibleCount {
    final provider = widget.visibleCountProvider;
    if (provider != null) return ref.watch(provider);
    return _localVisible;
  }

  void _loadMore() {
    final provider = widget.visibleCountProvider;
    if (provider != null) {
      ref.read(provider.notifier).state += widget.pageSize;
      return;
    }
    setState(() => _localVisible += widget.pageSize);
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
            child: Text(AppL10n.of(context).loadMoreRemaining(remaining)),
          ),
        ],
      ],
    );
  }
}
