import 'package:enfold/widgets/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('docked add shows on tab homes and Learn articles', () {
    expect(AppShell.showDockedQuickAdd('/'), isTrue);
    expect(AppShell.showDockedQuickAdd('/logs'), isTrue);
    expect(AppShell.showDockedQuickAdd('/learn'), isTrue);
    expect(AppShell.showDockedQuickAdd('/settings'), isTrue);
    expect(AppShell.showDockedQuickAdd('/learn/fever-newborn'), isTrue);
  });

  test('docked add hides on screens that already have a +', () {
    expect(AppShell.showDockedQuickAdd('/logs/sleep'), isFalse);
    expect(AppShell.showDockedQuickAdd('/logs/growth'), isFalse);
    expect(AppShell.showDockedQuickAdd('/growth'), isFalse);
    expect(AppShell.showDockedQuickAdd('/logs/feed/add'), isFalse);
    expect(AppShell.showDockedQuickAdd('/logs/feed'), isFalse);
    expect(AppShell.showDockedQuickAdd('/growth/add'), isFalse);
  });
}
