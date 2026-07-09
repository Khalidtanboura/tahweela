import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahweela/core/referral_taxonomy.dart';
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
    final referralRef = _firestore.collection('referrals').doc(referralId);
    final snapshot = await referralRef.get();
    final data = snapshot.data() ?? {};
    final rawReviews = data['medicalReviews'] as Map<String, dynamic>? ?? {};

    if (rawReviews.containsKey(reviewerId)) {
      throw Exception('تم تقييم هذه الحالة من قبلك مسبقا');
    }

    final reviewData = {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'score': score.toMap(),
      'totalScore': score.total,
      'priorityLevel': score.priorityLevel,
      'answers': answers,
      'notes': notes,
      'reviewedAt': FieldValue.serverTimestamp(),
    };
    final completedReviewCount = rawReviews.length + 1;

    final updateData = <String, dynamic>{
      'status': completedReviewCount >= 3
          ? _finalStatusForScore(
              _averageScore([...rawReviews.values, reviewData]),
            )
          : 'under_medical_review',
      'medicalReviews.$reviewerId': reviewData,
      'medicalReviewCount': completedReviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (completedReviewCount >= 3) {
      final averageTotal = _averageScore([...rawReviews.values, reviewData]);
      final finalScore = _scoreFromReviews([...rawReviews.values, reviewData]);
      final finalStatus = _finalStatusForScore(averageTotal);

      updateData.addAll({
        'medicalScore': finalScore.toMap(),
        'totalScore': finalScore.total,
        'averageMedicalScore': averageTotal,
        'priorityLevel': finalScore.priorityLevel,
        'finalMedicalDecision': finalStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
        'finalReviewedAt': FieldValue.serverTimestamp(),
      });
    }

    await referralRef.update(updateData);

    if (completedReviewCount >= 3) {
      final finalStatus = updateData['finalMedicalDecision']?.toString() ?? '';
      final patientUid = data['patientId']?.toString() ?? '';
      final patientName = data['patientName']?.toString() ?? '';
      final statusText = finalStatus == 'accepted' ? 'قبول' : 'رفض';
      final totalScore = updateData['totalScore']?.toString() ?? '0';

      if (patientUid.isNotEmpty) {
        await _notificationsRepo.sendNotificationToPatient(
          patientUid: patientUid,
          title: 'تم إصدار نتيجة تقييم حالتك',
          body:
              'تم $statusText الحالة بعد اكتمال تقييم 3 أطباء. النتيجة النهائية: $totalScore/100.',
          type: 'system_alert',
          relatedId: referralId,
          routeName: 'casePatient',
        );
      }

      await _notificationsRepo.sendNotificationToAdmin(
        title: 'اكتمل تقييم حالة طبية',
        body:
            'اكتمل تقييم حالة ${patientName.isEmpty ? 'مريض' : patientName} من 3 أطباء، والقرار النهائي: $statusText.',
        type: 'system_alert',
        relatedId: referralId,
        routeName: 'casesList',
      );
    }
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

  Future<List<ReferralModel>> fetchReferralModels({
    required String role,
    String? uid,
  }) async {
    Query query = _firestore
        .collection('referrals')
        .orderBy('createdAt', descending: true);

    if (role == 'doctor' && uid != null) {
      query = query.where('doctorId', isEqualTo: uid);
    } else if (role == 'patient' && uid != null) {
      query = query.where('patientId', isEqualTo: uid);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ReferralModel.fromFirestore(doc))
        .toList();
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
    String? reviewerId,
  }) {
    final normalizedSpecialty = normalizeSpecialty(specialty ?? '');
    if (normalizedSpecialty.isEmpty) {
      return Stream.value(const <ReferralModel>[]);
    }
    final query = _firestore.collection('referrals');

    return query.snapshots().map((snapshot) {
      final referrals = snapshot.docs
          .map((doc) => ReferralModel.fromFirestore(doc))
          .where((referral) {
            if (!_needsMedicalReview(referral.status)) return false;
            if (reviewerId != null && reviewerId.isNotEmpty) {
              final data = snapshot.docs
                  .firstWhere((doc) => doc.id == referral.id)
                  .data();
              final reviews =
                  data['medicalReviews'] as Map<String, dynamic>? ?? {};
              if (reviews.containsKey(reviewerId)) return false;
            }
            final assignedSpecialty = normalizeSpecialty(
              referral.assignedSpecialty,
            );
            final inferredSpecialty = specialtyForDiseaseType(
              referral.diseaseType,
            );

            return assignedSpecialty == normalizedSpecialty ||
                inferredSpecialty == normalizedSpecialty;
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

  Future<List<ReferralModel>> fetchMedicalReviewReferrals({
    String? specialty,
    String? reviewerId,
  }) async {
    final normalizedSpecialty = normalizeSpecialty(specialty ?? '');
    if (normalizedSpecialty.isEmpty) {
      return const <ReferralModel>[];
    }

    final snapshot = await _firestore.collection('referrals').get();
    final referrals = snapshot.docs
        .map((doc) => ReferralModel.fromFirestore(doc))
        .where((referral) {
          if (!_needsMedicalReview(referral.status)) return false;
          if (reviewerId != null && reviewerId.isNotEmpty) {
            final data = snapshot.docs
                .firstWhere((doc) => doc.id == referral.id)
                .data();
            final reviews = data['medicalReviews'] as Map<String, dynamic>? ?? {};
            if (reviews.containsKey(reviewerId)) return false;
          }
          final assignedSpecialty = normalizeSpecialty(
            referral.assignedSpecialty,
          );
          final inferredSpecialty = specialtyForDiseaseType(
            referral.diseaseType,
          );

          return assignedSpecialty == normalizedSpecialty ||
              inferredSpecialty == normalizedSpecialty;
        })
        .toList();

    referrals.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
      return bDate.compareTo(aDate);
    });

    return referrals;
  }

  static String specialtyForDiseaseType(String diseaseType) {
    return ReferralTaxonomy.specialtyForDiseaseType(diseaseType);
  }

  static String normalizeSpecialty(String specialty) {
    return ReferralTaxonomy.normalizeSpecialty(specialty);
  }

  static bool _needsMedicalReview(String status) {
    switch (status.trim().toLowerCase()) {
      case 'reviewed':
      case 'accepted':
      case 'rejected':
      case 'returned':
      case 'closed':
        return false;
      default:
        return true;
    }
  }

  static int _averageScore(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (runningTotal, review) {
      if (review is! Map) return runningTotal;
      final value = review['totalScore'];
      return runningTotal +
          (value is int ? value : int.tryParse('$value') ?? 0);
    });
    return (total / reviews.length).round().clamp(0, 100).toInt();
  }

  static MedicalScoreModel _scoreFromReviews(List<dynamic> reviews) {
    if (reviews.isEmpty) return MedicalScoreModel.empty();

    int averageField(String key) {
      final total = reviews.fold<int>(0, (runningTotal, review) {
        if (review is! Map) return runningTotal;
        final score = review['score'];
        if (score is! Map) return runningTotal;
        final value = score[key];
        return runningTotal +
            (value is int ? value : int.tryParse('$value') ?? 0);
      });
      return (total / reviews.length).round();
    }

    return MedicalScoreModel(
      coreMedical: averageField(
        'coreMedical',
      ).clamp(0, MedicalScoreModel.maxCoreMedical),
      delayImpact: averageField(
        'delayImpact',
      ).clamp(0, MedicalScoreModel.maxDelayImpact),
      treatability: averageField(
        'treatability',
      ).clamp(0, MedicalScoreModel.maxTreatability),
      resourceAdjustment: averageField('resourceAdjustment').clamp(
        MedicalScoreModel.minResourceAdjustment,
        MedicalScoreModel.maxResourceAdjustment,
      ),
    );
  }

  static String _finalStatusForScore(int score) {
    return score >= 50 ? 'accepted' : 'rejected';
  }
}
