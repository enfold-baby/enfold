import 'package:enfold/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('growth add path follows the current growth screen', () {
    expect(AppRoutes.growthAddFrom('/logs/growth'), AppRoutes.logsGrowthAdd);
    expect(
      AppRoutes.growthAddFrom('/logs/growth/add'),
      AppRoutes.logsGrowthAdd,
    );
    expect(AppRoutes.growthAddFrom('/growth'), AppRoutes.growthAdd);
  });
}
