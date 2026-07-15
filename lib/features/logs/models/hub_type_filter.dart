import '../../today/models/log_type.dart';

abstract final class HubTypeFilter {
  static const all = <LogType>{};

  static Set<LogType> selectAll() => {};

  static Set<LogType> toggleType(Set<LogType> current, LogType type) {
    if (current.isEmpty) return {type};

    final next = Set<LogType>.from(current);
    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }

    if (next.length == LogType.values.length) return {};
    return next;
  }

  static bool isAll(Set<LogType> selected) => selected.isEmpty;

  static String emptyMessage(Set<LogType> selected) {
    if (selected.isEmpty) {
      return 'No logs in this period. Open a type above to add one.';
    }
    if (selected.length == 1) {
      return 'No ${selected.first.label.toLowerCase()} logs in this period.';
    }
    final labels = selected.map((t) => t.label.toLowerCase()).join(', ');
    return 'No $labels logs in this period.';
  }
}