import 'package:cloud_firestore/cloud_firestore.dart';
import 'medical_score_model.dart';

class ReferralModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String diagnosis;
  final String reason;
  final String diseaseType;
  final String assignedSpecialty;
  final String status;
  final String adminReply;
  final MedicalScoreModel medicalScore;
  final int medicalReviewCount;
  final int averageMedicalScore;
  final String finalMedicalDecision;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? finalReviewedAt;

  const ReferralModel({
    this.id = '',
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.diagnosis,
    required this.reason,
    this.diseaseType = '',
    this.assignedSpecialty = '',
    this.status = 'pending',
    this.adminReply = '',
    this.medicalScore = const MedicalScoreModel(
      coreMedical: 0,
      delayImpact: 0,
      treatability: 0,
      resourceAdjustment: 0,
    ),
    this.medicalReviewCount = 0,
    this.averageMedicalScore = 0,
    this.finalMedicalDecision = '',
    this.createdAt,
    this.updatedAt,
    this.finalReviewedAt,
  });

  factory ReferralModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReferralModel.fromMap(data, id: doc.id);
  }

  factory ReferralModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    final diseaseType = _firstString(data, const [
      'diseaseType',
      'disease_type',
      'caseType',
      'specialty',
    ]);
    final diagnosis = _firstString(data, const [
      'diagnosis',
      'diagnose',
      'diseaseType',
      'caseType',
      'specialty',
    ]);

    return ReferralModel(
      id: id,
      doctorId: _firstString(data, const [
        'doctorId',
        'doctorUid',
        'doctor_id',
      ]),
      doctorName: _firstString(data, const [
        'doctorName',
        'doctor_name',
        'createdByName',
        'userName',
      ]),
      patientId: _firstString(data, const [
        'patientId',
        'patientUid',
        'patientNationalId',
        'nationalId',
      ]),
      patientName: _firstString(data, const [
        'patientName',
        'patientFullName',
        'fullName',
        'name',
      ]),
      diagnosis: diagnosis,
      reason: _firstString(data, const ['reason', 'notes', 'initialNotes']),
      diseaseType: diseaseType,
      assignedSpecialty: _firstString(data, const [
        'assignedSpecialty',
        'targetSpecialty',
        'specialty',
      ]),
      status: _firstString(data, const ['status'], fallback: 'pending'),
      adminReply: _firstString(data, const ['adminReply', 'reply']),
      medicalScore: MedicalScoreModel.fromMap(
        data['medicalScore'] as Map<String, dynamic>?,
      ),
      medicalReviewCount: _readMedicalReviewCount(data),
      averageMedicalScore: _readInt(
        data['averageMedicalScore'],
        fallback: _readInt(data['totalScore']),
      ).clamp(0, 100),
      finalMedicalDecision: _firstString(data, const ['finalMedicalDecision']),
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
      finalReviewedAt: _dateFromFirestore(data['finalReviewedAt']),
    );
  }

  String get priorityLevel => medicalScore.priorityLevel;

  int get totalScore => medicalScore.total;

  bool get hasFinalMedicalDecision => finalMedicalDecision.trim().isNotEmpty;

  int get remainingMedicalReviews => (3 - medicalReviewCount).clamp(0, 3);

  Map<String, dynamic> toMap({bool useServerTimestamp = true}) {
    final createdAtValue = createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!);

    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'diagnosis': diagnosis,
      'reason': reason,
      'diseaseType': diseaseType,
      'assignedSpecialty': assignedSpecialty,
      'status': status,
      'adminReply': adminReply,
      'medicalScore': medicalScore.toMap(),
      'priorityLevel': priorityLevel,
      'totalScore': totalScore,
      'medicalReviewCount': medicalReviewCount,
      'averageMedicalScore': averageMedicalScore,
      if (finalMedicalDecision.isNotEmpty)
        'finalMedicalDecision': finalMedicalDecision,
      'createdAt': useServerTimestamp ? createdAtValue : createdAt,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (finalReviewedAt != null)
        'finalReviewedAt': Timestamp.fromDate(finalReviewedAt!),
    };
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String _firstString(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static int _readMedicalReviewCount(Map<String, dynamic> data) {
    final storedCount = _readInt(data['medicalReviewCount']);
    if (storedCount > 0) return storedCount;

    final reviews = data['medicalReviews'];
    if (reviews is Map) return reviews.length;
    return 0;
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
