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
    return ReferralModel(
      id: id,
      doctorId: data['doctorId']?.toString() ?? '',
      doctorName: data['doctorName']?.toString() ?? '',
      patientId: data['patientId']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      diagnosis: data['diagnosis']?.toString() ?? '',
      reason: data['reason']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      adminReply: data['adminReply']?.toString() ?? '',
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
}
