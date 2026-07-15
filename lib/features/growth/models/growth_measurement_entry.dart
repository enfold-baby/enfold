class GrowthMeasurementEntry {
  const GrowthMeasurementEntry({
    required this.id,
    required this.measuredAt,
    this.weightKg,
    this.lengthCm,
    this.headCm,
    this.note = '',
  });

  final String id;
  final DateTime measuredAt;
  final double? weightKg;
  final double? lengthCm;
  final double? headCm;
  final String note;

  bool get hasAnyMeasurement =>
      weightKg != null || lengthCm != null || headCm != null;
}