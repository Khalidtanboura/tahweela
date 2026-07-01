import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahweela/data/models/medical_score_model.dart';
import 'package:tahweela/data/models/referral_model.dart';

import 'auth_repository.dart';
import 'notifications_repository.dart';
import 'public_users_repository.dart';

class ReferralsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsRepository _notificationsRepo;
  final AuthRepository _authRepository;
  final PublicUsersRepository _publicUsersRepository;

  ReferralsRepository({
    required NotificationsRepository notificationsRepo,
    AuthRepository? authRepository,
    PublicUsersRepository? publicUsersRepository,
  }) : _notificationsRepo = notificationsRepo,
       _authRepository = authRepository ?? AuthRepository(),
       _publicUsersRepository =
           publicUsersRepository ?? PublicUsersRepository();

  Future<void> createReferral({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String diagnosis,
    required String reason,
    String patientNationalId = '',
    String patientPhone = '',
    String diseaseType = '',
    List<Map<String, dynamic>> attachments = const [],
    List<Map<String, dynamic>> initialQuestions = const [],
    int initialScore = 0,
    String initialNotes = '',
  }) async {
    final patientUid = await _ensurePatientUid(patientId, phone: patientPhone);
    final assignedSpecialty = specialtyForDiseaseType(diseaseType);
    final referralData = ReferralModel(
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientUid,
      patientName: patientName,
      diagnosis: diagnosis,
      reason: reason,
      diseaseType: diseaseType,
      assignedSpecialty: assignedSpecialty,
      status: 'approved',
    ).toMap();

    referralData.addAll({
      'patientNationalId': patientNationalId,
      'patientPhone': patientPhone,
      'diseaseType': diseaseType,
      'assignedSpecialty': assignedSpecialty,
      'attachments': attachments,
      'initialQuestions': initialQuestions,
      'initialScore': initialScore,
      'initialNotes': initialNotes,
      'submittedForMedicalReviewAt': FieldValue.serverTimestamp(),
      'approvedAt': FieldValue.serverTimestamp(),
    });

    final referralDoc = await _firestore
        .collection('referrals')
        .add(referralData);

    try {
      await _notificationsRepo.sendNotificationToPatient(
        patientUid: patientUid,
        title: 'تم إنشاء حسابك وإرسال إحالتك',
        body: 'تم إنشاء حساب مريض لك وإرسال إحالتك للمراجعة الطبية.',
        type: 'new_referral',
        relatedId: referralDoc.id,
        routeName: 'casePatient',
      );
      await _notificationsRepo.sendNotificationToAllDoctors(
        title: 'تم تقديم إحالة جديدة',
        body: 'أرسل د. $doctorName تحويلا جديدا لـ $patientName.',
        type: 'new_referral',
        targetSpecialty: assignedSpecialty,
        relatedId: referralDoc.id,
        routeName: 'casesList',
      );
    } catch (_) {
      // The referral itself is the source of truth; notification failures should
      // not make the doctor lose a successfully submitted case.
    }
  }

  Future<void> approveReferral({
    required String referralId,
    required String doctorId,
    required String patientId,
    String adminReply = '',
  }) async {
    final patientUid = await _ensurePatientUid(patientId);
    final referralSnapshot = await _firestore
        .collection('referrals')
        .doc(referralId)
        .get();
    final referral = referralSnapshot.data() ?? {};
    final diseaseType = referral['diseaseType']?.toString() ?? '';
    final assignedSpecialty =
        referral['assignedSpecialty']?.toString().trim().isNotEmpty == true
        ? normalizeSpecialty(referral['assignedSpecialty'].toString())
        : specialtyForDiseaseType(diseaseType);

    await _firestore.collection('referrals').doc(referralId).update({
      'status': 'approved',
      'adminReply': adminReply,
      'patientId': patientUid,
      'assignedSpecialty': assignedSpecialty,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notificationsRepo.sendNotificationToPatient(
      patientUid: patientUid,
      title: 'تمت الموافقة على إحالتك',
      body: adminReply.isEmpty
          ? 'تمت الموافقة على إحالتك وإرسالها للمراجعة الطبية.'
          : 'تمت الموافقة على إحالتك. ملاحظة إدارية: $adminReply',
      type: 'new_referral',
      relatedId: referralId,
      routeName: 'casePatient',
    );

    await _notificationsRepo.sendNotificationToDoctor(
      doctorUid: doctorId,
      title: 'تمت الموافقة على الإحالة',
      body: adminReply.isEmpty
          ? 'تمت الموافقة على الإحالة وإرسالها للمراجعة الطبية.'
          : 'تمت الموافقة على الإحالة. ملاحظة إدارية: $adminReply',
      type: 'system_alert',
      relatedId: referralId,
      routeName: 'casesList',
    );

    await _notificationsRepo.sendNotificationToAllDoctors(
      title: 'حالة جديدة للمراجعة الطبية',
      body:
          'توجد حالة ${referral['patientName']?.toString().isEmpty == false ? referral['patientName'] : 'مريض'} ضمن تخصص $assignedSpecialty تحتاج إلى تقييم.',
      type: 'new_referral',
      targetSpecialty: assignedSpecialty,
      relatedId: referralId,
      routeName: 'casesList',
    );
  }

  Future<void> submitMedicalReview({
    required String referralId,
    required String reviewerId,
    required String reviewerName,
    required MedicalScoreModel score,
    required List<Map<String, dynamic>> answers,
    String notes = '',
  }) async {
    await _firestore.collection('referrals').doc(referralId).update({
      'status': 'reviewed',
      'medicalScore': score.toMap(),
      'totalScore': score.total,
      'priorityLevel': score.priorityLevel,
      'medicalReview': {
        'reviewerId': reviewerId,
        'reviewerName': reviewerName,
        'answers': answers,
        'notes': notes,
        'reviewedAt': FieldValue.serverTimestamp(),
      },
      'reviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _ensurePatientUid(
    String patientIdOrNationalId, {
    String phone = '',
  }) async {
    final existingUser = await _authRepository.findUserByNationalId(
      patientIdOrNationalId,
    );
    if (existingUser != null) return existingUser.uid;

    final publicUser = await _publicUsersRepository.findByNationalId(
      patientIdOrNationalId,
    );
    if (publicUser == null) return patientIdOrNationalId;
    if (publicUser.isLinked && publicUser.appUserUid != null) {
      return publicUser.appUserUid!;
    }

    final patient = await _authRepository.createLinkedUserFromPublicUser(
      publicUser: publicUser,
      role: 'patient',
      phone: phone,
      password: publicUser.nationalId,
    );
    return patient.uid;
  }

  Future<void> updateReferralStatus({
    required String referralId,
    required String doctorId,
    required String patientId,
    required String newStatus,
    required String adminReply,
  }) async {
    if (newStatus == 'accepted' || newStatus == 'approved') {
      await approveReferral(
        referralId: referralId,
        doctorId: doctorId,
        patientId: patientId,
        adminReply: adminReply,
      );
      return;
    }

    await _firestore.collection('referrals').doc(referralId).update({
      'status': newStatus,
      'adminReply': adminReply,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notificationsRepo.sendNotificationToDoctor(
      doctorUid: doctorId,
      title: 'تم تحديث حالة الإحالة',
      body: 'ملاحظة إدارية: $adminReply',
      type: 'system_alert',
    );
  }

  Stream<List<ReferralModel>> streamReferralModels({
    required String role,
    String? uid,
  }) {
    return streamReferrals(role: role, uid: uid).map(
      (snapshot) =>
          snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<QuerySnapshot> streamReferrals({required String role, String? uid}) {
    Query query = _firestore
        .collection('referrals')
        .orderBy('createdAt', descending: true);

    if (role == 'doctor' && uid != null) {
      query = query.where('doctorId', isEqualTo: uid);
    } else if (role == 'patient' && uid != null) {
      query = query.where('patientId', isEqualTo: uid);
    }

    return query.snapshots();
  }

  Stream<List<ReferralModel>> streamMedicalReviewReferrals({
    String? specialty,
  }) {
    final normalizedSpecialty = normalizeSpecialty(specialty ?? '');
    if (normalizedSpecialty.isEmpty) {
      return Stream.value(const <ReferralModel>[]);
    }
    final query = _firestore
        .collection('referrals')
        .where('status', whereIn: ['approved', 'accepted']);

    return query.snapshots().map((snapshot) {
      final referrals = snapshot.docs
          .map((doc) => ReferralModel.fromFirestore(doc))
          .where((referral) {
            if (normalizedSpecialty.isEmpty) return true;
            return normalizeSpecialty(referral.assignedSpecialty) ==
                normalizedSpecialty;
          })
          .toList();

      referrals.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      return referrals;
    });
  }

  static String specialtyForDiseaseType(String diseaseType) {
    switch (_cleanText(diseaseType)) {
      case 'أمراض الجهاز الهضمي والبطن':
      case 'أمراض الكبد والكلى والسكري':
        return 'باطنية';
      case 'إصابات العظام والمفاصل':
        return 'جراحة عظام';
      case 'أمراض القلب والأوعية الدموية':
        return 'قلب وأوعية دموية';
      case 'أمراض المخ والأعصاب':
        return 'مخ وأعصاب';
      case 'الأورام':
        return 'أورام';
      case 'أمراض الأطفال':
        return 'أطفال';
      case 'الحمل والولادة وصحة المرأة':
        return 'نساء وتوليد';
      case 'أمراض العيون':
        return 'عيون';
      case 'أمراض الأذن والأنف والحنجرة':
        return 'أنف وأذن وحنجرة';
      case 'الأمراض الجلدية':
        return 'جلدية';
      case 'الصحة النفسية':
        return 'طب نفسي';
      case 'حالات الطوارئ':
        return 'طوارئ';
      case 'حالات الجراحة العامة':
        return 'جراحة عامة';
      default:
        return 'باطنية';
    }
  }

  static String normalizeSpecialty(String specialty) {
    switch (_cleanText(specialty)) {
      case 'الطب الباطني':
      case 'باطنية':
        return 'باطنية';
      case 'طب القلب':
      case 'قلب وأوعية دموية':
        return 'قلب وأوعية دموية';
      case 'طب الأعصاب':
      case 'مخ وأعصاب':
        return 'مخ وأعصاب';
      case 'جراحة العظام':
      case 'جراحة عظام':
        return 'جراحة عظام';
      case 'طب الأورام':
      case 'أورام':
        return 'أورام';
      case 'طب الأطفال':
      case 'أطفال':
        return 'أطفال';
      case 'طب النساء والتوليد':
      case 'نساء وتوليد':
        return 'نساء وتوليد';
      case 'طب العيون':
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
      case 'طوارئ':
        return 'طوارئ';
      case 'الجراحة العامة':
      case 'جراحة عامة':
        return 'جراحة عامة';
      default:
        return _cleanText(specialty);
    }
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
