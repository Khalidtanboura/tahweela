import 'package:cloud_firestore/cloud_firestore.dart';
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
    final referralData = ReferralModel(
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      patientName: patientName,
      diagnosis: diagnosis,
      reason: reason,
    ).toMap();

    referralData.addAll({
      'patientNationalId': patientNationalId,
      'patientPhone': patientPhone,
      'diseaseType': diseaseType,
      'attachments': attachments,
      'initialQuestions': initialQuestions,
      'initialScore': initialScore,
      'initialNotes': initialNotes,
      'submittedForAdminReviewAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('referrals').add(referralData);

    await _notificationsRepo.sendNotificationToAdmin(
      title: '??? ????? ??? ????',
      body: '??? ?. $doctorName ?????? ????? ?????? $patientName.',
      type: 'new_referral',
    );
  }

  Future<void> approveReferral({
    required String referralId,
    required String doctorId,
    required String patientId,
    String adminReply = '',
  }) async {
    final patientUid = await _ensurePatientUid(patientId);

    await _firestore.collection('referrals').doc(referralId).update({
      'status': 'approved',
      'adminReply': adminReply,
      'patientId': patientUid,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notificationsRepo.sendNotificationToPatient(
      patientUid: patientUid,
      title: '?? ?????? ?????? ?????',
      body: adminReply.isEmpty
          ? '?? ?????? ??????? ??????? ??? ?????? ????? ??????.'
          : '?? ?????? ??????? ???????. ?????? ???????: $adminReply',
      type: 'new_referral',
    );

    await _notificationsRepo.sendNotificationToDoctor(
      doctorUid: doctorId,
      title: '?? ?????? ???????',
      body: adminReply.isEmpty
          ? '?? ?????? ??????? ???? ?????? ??? ?????? ????? ??????.'
          : '?? ?????? ??????? ???? ??????. ?????? ???????: $adminReply',
      type: 'system_alert',
    );

    await _notificationsRepo.sendNotificationToAllDoctors(
      title: '????? ????? ???????',
      body: '???? ????? ????? ??????? ??????? ????????.',
      type: 'new_referral',
    );
  }

  Future<String> _ensurePatientUid(String patientIdOrNationalId) async {
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
      phone: '',
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
      title: '??? ????? ??????? ????????',
      body: '?????? ???????: $adminReply',
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

  Stream<List<ReferralModel>> streamMedicalReviewReferrals() {
    return _firestore
        .collection('referrals')
        .where('status', whereIn: ['approved', 'accepted'])
        .snapshots()
        .map((snapshot) {
          final referrals = snapshot.docs
              .map((doc) => ReferralModel.fromFirestore(doc))
              .toList();

          referrals.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt ?? DateTime(0);
            final bDate = b.updatedAt ?? b.createdAt ?? DateTime(0);
            return bDate.compareTo(aDate);
          });

          return referrals;
        });
  }
}
