import '../../../l10n/generated/app_localizations.dart';

class MedicationPreset {
  const MedicationPreset({
    required this.id,
    required this.category,
    this.hasSuggestedDose = false,
  });

  /// Stable across languages: widget keys and selection use it, never the name.
  final String id;
  final String category;
  final bool hasSuggestedDose;

  String name(AppL10n l10n) => switch (id) {
        'vitamin_d' => l10n.medicationPresetVitaminD,
        'multivitamin' => l10n.medicationPresetMultivitamin,
        'iron' => l10n.medicationPresetIron,
        'probiotic' => l10n.medicationPresetProbiotic,
        'acetaminophen' => l10n.medicationPresetAcetaminophen,
        'ibuprofen' => l10n.medicationPresetIbuprofen,
        _ => l10n.medicationPresetAntibiotic,
      };

  String? suggestedDose(AppL10n l10n) => switch (id) {
        'vitamin_d' => l10n.medicationDoseOneDrop,
        'iron' => l10n.medicationDoseOneMl,
        'acetaminophen' || 'ibuprofen' => l10n.medicationDosePerPediatrician,
        _ => null,
      };
}

abstract final class MedicationPresets {
  /// Stored category values; [categoryLabel] is what the chips show.
  static const categoryValues = ['vitamin', 'supplement', 'medication'];

  static String categoryLabel(AppL10n l10n, String value) => switch (value) {
        'vitamin' => l10n.medicationCategoryVitamin,
        'supplement' => l10n.medicationCategorySupplement,
        _ => l10n.medicationCategoryMedication,
      };

  static const presets = [
    MedicationPreset(
      id: 'vitamin_d',
      category: 'vitamin',
      hasSuggestedDose: true,
    ),
    MedicationPreset(id: 'multivitamin', category: 'vitamin'),
    MedicationPreset(id: 'iron', category: 'supplement', hasSuggestedDose: true),
    MedicationPreset(id: 'probiotic', category: 'supplement'),
    MedicationPreset(
      id: 'acetaminophen',
      category: 'medication',
      hasSuggestedDose: true,
    ),
    MedicationPreset(
      id: 'ibuprofen',
      category: 'medication',
      hasSuggestedDose: true,
    ),
    MedicationPreset(id: 'antibiotic', category: 'medication'),
  ];

  static List<MedicationPreset> forCategory(String? category) {
    if (category == null) return presets;
    return [
      for (final preset in presets)
        if (preset.category == category) preset,
    ];
  }
}
