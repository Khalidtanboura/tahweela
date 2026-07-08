import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalScoreModel {
  static const int maxCoreMedical = 40;
  static const int maxDelayImpact = 25;
  static const int maxTreatability = 20;
  static const int minResourceAdjustment = -15;
  static const int maxResourceAdjustment = 15;

  final int coreMedical;
  final int delayImpact;
  final int treatability;
  final int resourceAdjustment;

  const MedicalScoreModel({
    required this.coreMedical,
    required this.delayImpact,
    required this.treatability,
    required this.resourceAdjustment,
  }) : assert(coreMedical >= 0 && coreMedical <= maxCoreMedical),
       assert(delayImpact >= 0 && delayImpact <= maxDelayImpact),
       assert(treatability >= 0 && treatability <= maxTreatability),
       assert(
         resourceAdjustment >= minResourceAdjustment &&
             resourceAdjustment <= maxResourceAdjustment,
       );

  factory MedicalScoreModel.empty() {
    return const MedicalScoreModel(
      coreMedical: 0,
      delayImpact: 0,
      treatability: 0,
      resourceAdjustment: 0,
    );
  }

  factory MedicalScoreModel.fromMap(Map<String, dynamic>? data) {
    final scoreData = data ?? {};
    return MedicalScoreModel(
      coreMedical: _readBoundedInt(scoreData['coreMedical'], 0, maxCoreMedical),
      delayImpact: _readBoundedInt(scoreData['delayImpact'], 0, maxDelayImpact),
      treatability: _readBoundedInt(
        scoreData['treatability'],
        0,
        maxTreatability,
      ),
      resourceAdjustment: _readBoundedInt(
        scoreData['resourceAdjustment'],
        minResourceAdjustment,
        maxResourceAdjustment,
      ),
    );
  }

  int get total =>
      (coreMedical + delayImpact + treatability + resourceAdjustment)
          .clamp(0, 100)
          .toInt();

  String get priorityLevel {
    if (total >= 90) return 'critical';
    if (total >= 75) return 'high';
    if (total >= 50) return 'medium';
    return 'low';
  }

  Map<String, dynamic> toMap() {
    return {
      'coreMedical': coreMedical,
      'delayImpact': delayImpact,
      'treatability': treatability,
      'resourceAdjustment': resourceAdjustment,
      'total': total,
      'priorityLevel': priorityLevel,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static int _readBoundedInt(dynamic value, int min, int max) {
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    return (parsed ?? 0).clamp(min, max).toInt();
  }
}
