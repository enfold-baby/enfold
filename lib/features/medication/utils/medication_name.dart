String normalizeMedicationName(String raw) => raw.trim().toLowerCase();

bool sameMedicationName(String a, String b) =>
    normalizeMedicationName(a) == normalizeMedicationName(b) &&
    normalizeMedicationName(a).isNotEmpty;
