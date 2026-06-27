import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_repository.dart';

class ReferralsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsRepository _notificationsRepo;

  ReferralsRepository({required NotificationsRepository notificationsRepo})
    : _notificationsRepo = notificationsRepo;

  // 1. إنشاء تحويل طبي جديد (من قِبل الطبيب)
  Future<void> createReferral({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String diagnosis,
    required String reason,
  }) async {
    // حفظ التحويل في قاعدة البيانات
    await _firestore.collection('referrals').add({
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'diagnosis': diagnosis,
      'reason': reason,
      'status': 'pending', // pending, accepted, rejected, returned
      'adminReply': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // إرسال إشعار فوري للمدير
    await _notificationsRepo.sendNotificationToAdmin(
      title: 'طلب تحويل طبي جديد 📄',
      body: 'قام د. $doctorName برفع تحويل للمريض $patientName.',
      type: 'new_referral',
    );
  }

  // 2. تحديث حالة التحويل (من قِبل المدير)
  Future<void> updateReferralStatus({
    required String referralId,
    required String doctorId,
    required String patientId,
    required String newStatus, // 'accepted' أو 'rejected' أو 'returned'
    required String adminReply,
  }) async {
    // تحديث الحالة في قاعدة البيانات
    await _firestore.collection('referrals').doc(referralId).update({
      'status': newStatus,
      'adminReply': adminReply,
    });

    // إرسال الإشعارات بناءً على الحالة الجديدة
    if (newStatus == 'accepted') {
      await _notificationsRepo.sendNotificationToPatient(
        patientUid: patientId,
        title: 'تم قبول تحويلك الطبي 🎉',
        body: 'وافقت الإدارة على طلب تحويلك. ملاحظات: $adminReply',
        type: 'new_referral',
      );
      await _notificationsRepo.sendNotificationToDoctor(
        doctorUid: doctorId,
        title: 'تم اعتماد التحويل',
        body: 'تم قبول التحويل الخاص بمريضك. ملاحظات: $adminReply',
        type: 'system_alert',
      );
    } else {
      // في حالة الرفض أو الإرجاع، نبلغ الطبيب فقط
      String statusAr = newStatus == 'rejected' ? 'رفض' : 'إرجاع';
      await _notificationsRepo.sendNotificationToDoctor(
        doctorUid: doctorId,
        title: 'تم $statusAr طلب التحويل ⚠️',
        body: 'السبب: $adminReply',
        type: 'system_alert',
      );
    }
  }

  // 3. جلب التحويلات كـ Stream (حي)
  Stream<QuerySnapshot> streamReferrals({required String role, String? uid}) {
    Query query = _firestore
        .collection('referrals')
        .orderBy('createdAt', descending: true);

    // تصفية ذكية بناءً على الدور
    if (role == 'doctor' && uid != null) {
      query = query.where('doctorId', isEqualTo: uid);
    } else if (role == 'patient' && uid != null) {
      query = query.where('patientId', isEqualTo: uid);
    }
    // الإدمن يرى كل شيء فلا نضع له where

    return query.snapshots();
  }
}
