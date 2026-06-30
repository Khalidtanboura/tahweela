import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahweela/data/models/referral_model.dart';
import 'notifications_repository.dart';

class ReferralsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsRepository _notificationsRepo;

  ReferralsRepository({required NotificationsRepository notificationsRepo})
    : _notificationsRepo = notificationsRepo;

  Future<void> createReferral({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String diagnosis,
    required String reason,
  }) async {
    final referral = ReferralModel(
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      patientName: patientName,
      diagnosis: diagnosis,
      reason: reason,
    );

    await _firestore.collection('referrals').add(referral.toMap());

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
    await _firestore.collection('referrals').doc(referralId).update({
      'status': 'approved',
      'adminReply': adminReply,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notificationsRepo.sendNotificationToPatient(
      patientUid: patientId,
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
}
