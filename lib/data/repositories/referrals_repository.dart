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
    final normalizedDiseaseType = diseaseType.trim();
    final assignedSpecialty = specialtyForDiseaseType(normalizedDiseaseType);
    final resolvedPatientName = await _resolvePatientName(
      patientName: patientName,
      patientIdOrNationalId: patientId,
    );
    final resolvedDoctorName = await _resolveDoctorName(
      doctorName: doctorName,
      doctorId: doctorId,
    );
    final resolvedDiagnosis = diagnosis.trim().isEmpty
        ? normalizedDiseaseType
        : diagnosis.trim();
    final resolvedReason = reason.trim();
    final referralData = ReferralModel(
      doctorId: doctorId,
      doctorName: resolvedDoctorName,
      patientId: patientUid,
      patientName: resolvedPatientName,
      diagnosis: resolvedDiagnosis,
      reason: resolvedReason,
      diseaseType: normalizedDiseaseType,
      assignedSpecialty: assignedSpecialty,
      status: 'approved',
    ).toMap();

    referralData.addAll({
      'patientNationalId': patientNationalId,
      'patientPhone': patientPhone,
      'diseaseType': normalizedDiseaseType,
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
        body:
            'New referral from Dr. $resolvedDoctorName for $resolvedPatientName.',
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

    final completion = await _firestore
        .runTransaction<_MedicalReviewCompletion?>((transaction) async {
          final snapshot = await transaction.get(referralRef);
          final data = snapshot.data() ?? {};
          final currentStatus = data['status']?.toString() ?? '';
          final rawReviews = _reviewMapFrom(data['medicalReviews']);

          if (_isFinalStatus(currentStatus) ||
              data['finalMedicalDecision'] != null) {
            throw Exception('?? ????? ????? ??? ?????? ?????');
          }

          if (rawReviews.containsKey(reviewerId)) {
            throw Exception('?? ????? ??? ?????? ?? ???? ?????');
          }

          final reviews = [...rawReviews.values, reviewData];
          final completedReviewCount = reviews.length;
          final updateData = <String, dynamic>{
            'status': completedReviewCount >= 3
                ? _finalStatusForScore(_averageScore(reviews))
                : 'under_medical_review',
            'medicalReviews.$reviewerId': reviewData,
            'medicalReviewCount': completedReviewCount,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (completedReviewCount < 3) {
            transaction.update(referralRef, updateData);
            return null;
          }

          final averageTotal = _averageScore(reviews);
          final finalScore = _scoreFromReviews(reviews);
          final finalStatus = _finalStatusForScore(averageTotal);

          updateData.addAll({
            'status': finalStatus,
            'medicalScore': finalScore.toMap(),
            'totalScore': finalScore.total,
            'averageMedicalScore': averageTotal,
            'priorityLevel': finalScore.priorityLevel,
            'finalMedicalDecision': finalStatus,
            'reviewedAt': FieldValue.serverTimestamp(),
            'finalReviewedAt': FieldValue.serverTimestamp(),
            'medicalDecisionNotifiedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(referralRef, updateData);

          return _MedicalReviewCompletion(
            finalStatus: finalStatus,
            totalScore: finalScore.total,
            patientIdOrNationalId: data['patientId']?.toString() ?? '',
            patientNationalId: data['patientNationalId']?.toString() ?? '',
            patientName: data['patientName']?.toString() ?? '',
          );
        });

    if (completion != null) {
      final patientUid = await _resolvePatientUidForNotification(
        patientIdOrNationalId: completion.patientIdOrNationalId,
        patientNationalId: completion.patientNationalId,
      );
      final statusText = completion.finalStatus == 'accepted' ? '????' : '???';

      if (patientUid.isNotEmpty) {
        await _notificationsRepo.sendNotificationToPatient(
          patientUid: patientUid,
          title: '?? ????? ????? ????? ?????',
          body:
              '?? $statusText ?????? ??? ?????? ????? 3 ?????. ??????? ????????: ${completion.totalScore}/100.',
          type: 'system_alert',
          relatedId: referralId,
          routeName: 'casePatient',
        );
      }

      await _notificationsRepo.sendNotificationToAdmin(
        title: '????? ????? ???? ????',
        body:
            '????? ????? ???? ${completion.patientName.isEmpty ? '????' : completion.patientName} ?? 3 ?????? ??????? ???????: $statusText.',
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

  Future<String> _resolvePatientName({
    required String patientName,
    required String patientIdOrNationalId,
  }) async {
    final trimmedName = patientName.trim();
    if (trimmedName.isNotEmpty) return trimmedName;

    final existingUser = await _authRepository.findUserByNationalId(
      patientIdOrNationalId,
    );
    if (existingUser != null && existingUser.name.trim().isNotEmpty) {
      return existingUser.name.trim();
    }

    final publicUser = await _publicUsersRepository.findByNationalId(
      patientIdOrNationalId,
    );
    if (publicUser != null && publicUser.fullName.trim().isNotEmpty) {
      return publicUser.fullName.trim();
    }

    return patientIdOrNationalId.trim();
  }

  Future<String> _resolvePatientUidForNotification({
    required String patientIdOrNationalId,
    required String patientNationalId,
  }) async {
    final primary = patientIdOrNationalId.trim();
    if (primary.isEmpty) return '';

    final userByUid = await _firestore.collection('users').doc(primary).get();
    if (userByUid.exists) return primary;

    final existingUser = await _authRepository.findUserByNationalId(primary);
    if (existingUser != null) return existingUser.uid;

    final nationalId = patientNationalId.trim();
    if (nationalId.isNotEmpty) {
      final userByNationalId = await _authRepository.findUserByNationalId(
        nationalId,
      );
      if (userByNationalId != null) return userByNationalId.uid;
    }

    return primary;
  }

  Future<String> _resolveDoctorName({
    required String doctorName,
    required String doctorId,
  }) async {
    final trimmedName = doctorName.trim();
    if (trimmedName.isNotEmpty) return trimmedName;

    final snapshot = await _firestore.collection('users').doc(doctorId).get();
    final data = snapshot.data();
    final storedName = data?['name']?.toString().trim() ?? '';
    if (storedName.isNotEmpty) return storedName;

    return doctorId;
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
    Query query = _firestore.collection('referrals');

    if (role == 'doctor' && uid != null) {
      query = query.where('doctorId', isEqualTo: uid);
    } else if (role == 'patient' && uid != null) {
      query = query.where('patientId', isEqualTo: uid);
    }

    final snapshot = await query.get();
    final referrals = snapshot.docs
        .map((doc) => ReferralModel.fromFirestore(doc))
        .toList();
    _sortNewestFirst(referrals);
    return referrals;
  }

  Stream<QuerySnapshot> streamReferrals({required String role, String? uid}) {
    Query query = _firestore.collection('referrals');

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
            if (reviewerId != null &&
                reviewerId.isNotEmpty &&
                referral.doctorId == reviewerId) {
              return false;
            }
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

      _sortNewestFirst(referrals);

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
          if (reviewerId != null &&
              reviewerId.isNotEmpty &&
              referral.doctorId == reviewerId) {
            return false;
          }
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

    _sortNewestFirst(referrals);

    return referrals;
  }

  static void _sortNewestFirst(List<ReferralModel> referrals) {
    referrals.sort((a, b) {
      final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
      return bDate.compareTo(aDate);
    });
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

  static bool _isFinalStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'accepted':
      case 'rejected':
      case 'returned':
      case 'closed':
        return true;
      default:
        return false;
    }
  }

  static Map<String, dynamic> _reviewMapFrom(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
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

class _MedicalReviewCompletion {
  const _MedicalReviewCompletion({
    required this.finalStatus,
    required this.totalScore,
    required this.patientIdOrNationalId,
    required this.patientNationalId,
    required this.patientName,
  });

  final String finalStatus;
  final int totalScore;
  final String patientIdOrNationalId;
  final String patientNationalId;
  final String patientName;
}
