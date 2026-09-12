import 'package:enfold/features/logs/models/hub_type_filter.dart';
import 'package:enfold/features/today/models/log_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HubTypeFilter', () {
    test('All clears individual selections', () {
      expect(HubTypeFilter.selectAll(), isEmpty);
      expect(HubTypeFilter.isAll({}), isTrue);
    });

    test('from All to Feed selects only Feed', () {
      final next = HubTypeFilter.toggleType({}, LogType.feed);
      expect(next, {LogType.feed});
    });

    test('Feed plus Diaper keeps both selected', () {
      final next = HubTypeFilter.toggleType({LogType.feed}, LogType.diaper);
      expect(next, {LogType.feed, LogType.diaper});
    });

    test('tapping selected type removes it', () {
      final next = HubTypeFilter.toggleType(
        {LogType.feed, LogType.diaper},
        LogType.feed,
      );
      expect(next, {LogType.diaper});
    });

    test('selecting every type returns to All', () {
      var selected = <LogType>{};
      for (final type in LogType.values) {
        selected = HubTypeFilter.toggleType(selected, type);
      }
      expect(selected, isEmpty);
    });
  });
}