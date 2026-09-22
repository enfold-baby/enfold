import '../../../l10n/generated/app_localizations.dart';
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

  static String emptyMessage(AppL10n l10n, Set<LogType> selected) {
    if (selected.isEmpty) return l10n.logsEmptyAll;
    final labels =
        selected.map((t) => t.label(l10n).toLowerCase()).join(', ');
    return l10n.logsEmptyForTypes(labels);
  }
}