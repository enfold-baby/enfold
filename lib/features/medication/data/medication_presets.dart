class MedicationPreset {
  const MedicationPreset({
    required this.category,
    required this.name,
    this.suggestedDose,
  });

  final String category;
  final String name;
  final String? suggestedDose;
}

abstract final class MedicationPresets {
  static const categories = [
    ('vitamin', 'Vitamin'),
    ('supplement', 'Supplement'),
    ('medication', 'Medication'),
  ];

  static const presets = [
    MedicationPreset(
      category: 'vitamin',
      name: 'Vitamin D drops',
      suggestedDose: '1 drop',
    ),
    MedicationPreset(
      category: 'vitamin',
      name: 'Multivitamin drops',
    ),
    MedicationPreset(
      category: 'supplement',
      name: 'Iron drops',
      suggestedDose: '1 ml',
    ),
    MedicationPreset(
      category: 'supplement',
      name: 'Probiotic drops',
    ),
    MedicationPreset(
      category: 'medication',
      name: 'Acetaminophen',
      suggestedDose: 'per pediatrician',
    ),
    MedicationPreset(
      category: 'medication',
      name: 'Ibuprofen',
      suggestedDose: 'per pediatrician',
    ),
    MedicationPreset(
      category: 'medication',
      name: 'Antibiotic',
    ),
  ];

  static List<MedicationPreset> forCategory(String? category) {
    if (category == null) return presets;
    return [
      for (final preset in presets)
        if (preset.category == category) preset,
    ];
  }
}