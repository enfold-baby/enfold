import 'package:enfold/core/datetime/log_date_bounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('log date bounds span three years back and tomorrow', () {
    final now = DateTime(2026, 9, 3, 11, 27);
    expect(LogDateBounds.firstDate(now), DateTime(2023, 9, 3));
    expect(LogDateBounds.lastDate(now), DateTime(2026, 9, 4));
    expect(
      LogDateBounds.clampInitial(DateTime(2020, 1, 1), now: now),
      DateTime(2023, 9, 3),
    );
  });
}
