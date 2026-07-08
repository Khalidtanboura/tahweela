import 'dart:convert';

class ReferralTaxonomy {
  static const specialties = [
    'باطنية',
    'قلب وأوعية دموية',
    'مخ وأعصاب',
    'جراحة عظام',
    'جراحة عامة',
    'أورام',
    'أطفال',
    'نساء وتوليد',
    'عيون',
    'أنف وأذن وحنجرة',
    'جلدية',
    'طب نفسي',
    'طوارئ',
  ];

  static const diseaseTypes = [
    'أمراض البطن والجهاز الهضمي',
    'أمراض الكبد والكلى والسكري',
    'إصابات العظام والمفاصل',
    'أمراض القلب والأوعية الدموية',
    'أمراض الدماغ والأعصاب',
    'الأورام',
    'أمراض الأطفال',
    'الحمل والولادة والنساء',
    'أمراض العيون',
    'الأنف والأذن والحنجرة',
    'الأمراض الجلدية',
    'الصحة النفسية',
    'حالات جراحية عامة',
    'حالات طارئة',
  ];

  static String specialtyForDiseaseType(String diseaseType) {
    switch (_normalizeDiseaseType(diseaseType)) {
      case 'أمراض البطن والجهاز الهضمي':
      case 'أمراض الجهاز الهضمي والبطن':
      case 'أمراض الكبد والكلى والسكري':
        return 'باطنية';
      case 'إصابات العظام والمفاصل':
        return 'جراحة عظام';
      case 'أمراض القلب والأوعية الدموية':
      case 'القلب':
        return 'قلب وأوعية دموية';
      case 'أمراض الدماغ والأعصاب':
      case 'أمراض المخ والأعصاب':
      case 'الدماغ':
        return 'مخ وأعصاب';
      case 'الأورام':
        return 'أورام';
      case 'أمراض الأطفال':
        return 'أطفال';
      case 'الحمل والولادة والنساء':
      case 'الحمل والولادة وصحة المرأة':
        return 'نساء وتوليد';
      case 'أمراض العيون':
        return 'عيون';
      case 'الأنف والأذن والحنجرة':
      case 'أمراض الأذن والأنف والحنجرة':
        return 'أنف وأذن وحنجرة';
      case 'الأمراض الجلدية':
        return 'جلدية';
      case 'الصحة النفسية':
        return 'طب نفسي';
      case 'حالات جراحية عامة':
      case 'حالات الجراحة العامة':
        return 'جراحة عامة';
      case 'حالات طارئة':
      case 'حالات الطوارئ':
        return 'طوارئ';
      default:
        return 'باطنية';
    }
  }

  static String normalizeSpecialty(String specialty) {
    switch (_cleanText(specialty)) {
      case 'الطب الباطني':
      case 'الباطنية':
      case 'باطنية':
        return 'باطنية';
      case 'طب القلب':
      case 'القلب':
      case 'قلب وأوعية دموية':
        return 'قلب وأوعية دموية';
      case 'طب الأعصاب':
      case 'الدماغ':
      case 'مخ وأعصاب':
        return 'مخ وأعصاب';
      case 'جراحة العظام':
      case 'العظام':
      case 'جراحة عظام':
        return 'جراحة عظام';
      case 'الجراحة العامة':
      case 'جراحة عامة':
        return 'جراحة عامة';
      case 'طب الأورام':
      case 'الأورام':
      case 'أورام':
        return 'أورام';
      case 'طب الأطفال':
      case 'الأطفال':
      case 'أطفال':
        return 'أطفال';
      case 'طب النساء والتوليد':
      case 'نساء وتوليد':
        return 'نساء وتوليد';
      case 'طب العيون':
      case 'العيون':
      case 'عيون':
        return 'عيون';
      case 'أذن وأنف وحنجرة':
      case 'أنف وأذن وحنجرة':
        return 'أنف وأذن وحنجرة';
      case 'طب الجلدية':
      case 'جلدية':
        return 'جلدية';
      case 'الطب النفسي':
      case 'طب نفسي':
        return 'طب نفسي';
      case 'طب الطوارئ':
      case 'الطوارئ':
      case 'طوارئ':
        return 'طوارئ';
      default:
        return _cleanText(specialty);
    }
  }

  static String _normalizeDiseaseType(String diseaseType) {
    return _cleanText(diseaseType)
        .replaceAll('الجهاز الهضمي و البطن', 'الجهاز الهضمي والبطن')
        .replaceAll('البطن و الجهاز الهضمي', 'البطن والجهاز الهضمي')
        .replaceAll('المخ', 'الدماغ');
  }

  static String _cleanText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    try {
      final repaired = utf8.decode(_windows1252Bytes(trimmed));
      if (repaired.contains(RegExp(r'[\u0600-\u06FF]'))) {
        return repaired.trim();
      }
    } catch (_) {
      // Keep the original value when it is already valid UTF-8 text.
    }
    return trimmed;
  }

  static List<int> _windows1252Bytes(String value) {
    const replacements = {
      0x20AC: 0x80,
      0x201A: 0x82,
      0x0192: 0x83,
      0x201E: 0x84,
      0x2026: 0x85,
      0x2020: 0x86,
      0x2021: 0x87,
      0x02C6: 0x88,
      0x2030: 0x89,
      0x0160: 0x8A,
      0x2039: 0x8B,
      0x0152: 0x8C,
      0x017D: 0x8E,
      0x2018: 0x91,
      0x2019: 0x92,
      0x201C: 0x93,
      0x201D: 0x94,
      0x2022: 0x95,
      0x2013: 0x96,
      0x2014: 0x97,
      0x02DC: 0x98,
      0x2122: 0x99,
      0x0161: 0x9A,
      0x203A: 0x9B,
      0x0153: 0x9C,
      0x017E: 0x9E,
      0x0178: 0x9F,
    };

    return value.runes
        .map((codePoint) => replacements[codePoint] ?? codePoint)
        .where((codePoint) => codePoint >= 0 && codePoint <= 255)
        .toList();
  }
}
