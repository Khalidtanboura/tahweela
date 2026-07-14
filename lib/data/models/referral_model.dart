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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  String get priorityLevel => medicalScore.priorityLevel;

  int get totalScore => medicalScore.total;

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
      'createdAt': useServerTimestamp ? createdAtValue : createdAt,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
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
}
