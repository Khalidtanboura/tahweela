import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // استماع حي (Stream) للإشعارات الموجهة لدور معين أو مستخدم محدد مرتبة بالأحدث
  Stream<List<NotificationModel>> streamNotifications({
    required String role,
    required String uid,
  }) {
    return _firestore
        .collection('notifications')
        .where('targetRole', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          List<NotificationModel> allNotifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          // تصفية إضافية: جلب الإشعارات العامة للدور بأكمله، أو المخصصة لهذا الـ UID تحديداً
          return allNotifications.where((notif) {
            return notif.targetUid == null || notif.targetUid == uid;
          }).toList();
        });
  }

  // تحديث حالة الإشعار كمقروء عند الضغط عليه
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> sendNotificationToAdmin({
    required String title,
    required String body,
    required String type, // 'new_referral' أو 'complaint_update'
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'targetRole': 'admin',
      'targetUid': null, // عام لكل المدراء في لوحة التحكم
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// ب) إشعارات موجهة إلى [طبيب محدد]
  /// تُستدعى عند: رد المدير على شكوى الطبيب، أو إرجاع حالة من المدير للطبيب لإعادة النظر فيها
  Future<void> sendNotificationToDoctor({
    required String doctorUid,
    required String title,
    required String body,
    required String type, // 'complaint_update' أو 'system_alert'
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'targetRole': 'doctor',
      'targetUid': doctorUid, // يصل لهذا الطبيب فقط دون غيره
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// ج) إشعارات موجهة إلى [مريض محدد]
  /// تُستدعى عند: قبول المدير لتحويل المريض، تحديث الملف الصحي، أو الرد على شكوى المريض
  Future<void> sendNotificationToPatient({
    required String patientUid,
    required String title,
    required String body,
    required String type, // 'system_alert' أو 'complaint_update'
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'targetRole': 'patient',
      'targetUid': patientUid, // يصل لهذا المريض فقط لحماية خصوصيته الطبية
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
