import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahweela/data/models/complaint_model.dart';
import 'notifications_repository.dart'; // استيراد ملف الإشعارات

class ComplaintsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsRepository _notificationsRepo;

  ComplaintsRepository({required NotificationsRepository notificationsRepo})
    : _notificationsRepo = notificationsRepo;

  // =============================================================
  // 1. دالة إضافة شكوى جديدة (قم بإضافتها هنا لتنبيه المدير)
  // =============================================================
  Future<void> addComplaint({
    required String userId,
    required String userName,
    required String userRole,
    required String complaintText,
  }) async {
    // أولاً: حفظ الشكوى في الفايربيز بمجموعة complaints
    final complaint = ComplaintModel(
      userId: userId,
      userName: userName,
      userRole: userRole,
      text: complaintText,
    );

    final complaintDoc = await _firestore
        .collection('complaints')
        .add(complaint.toMap());

    // ثانياً: إرسال الإشعار التلقائي للمدير فوراً عند نجاح الحفظ
    await _notificationsRepo.sendNotificationToAdmin(
      title: 'شكوى جديدة في النظام ⚠️',
      body: 'قام $userName بتقديم شكوى بخصوص: $complaintText',
      type: 'complaint_update',
      relatedId: complaintDoc.id,
      routeName: 'complaintsView',
    );
  }

  // =============================================================
  // 2. دالة الرد على الشكوى (موجودة لديك بالفعل لتنبيه المستخدمين)
  // =============================================================
  Future<void> replyToComplaint({
    required String complaintId,
    required String targetUid,
    required String targetRole,
    required String replyText,
  }) async {
    // تحديث الرد والحالة في الفايربيز
    await _firestore.collection('complaints').doc(complaintId).update({
      'replyText': replyText,
      'status': 'accepted',
    });

    // إرسال الإشعار حسب دور الشخص (طبيب أو مريض)
    if (targetRole == 'doctor') {
      await _notificationsRepo.sendNotificationToDoctor(
        doctorUid: targetUid,
        title: 'تم الرد على شكواك التقنية',
        body: 'رد الإدارة: $replyText',
        type: 'complaint_update',
        relatedId: complaintId,
        routeName: 'complaintsDoctorCase',
      );
    } else if (targetRole == 'patient') {
      await _notificationsRepo.sendNotificationToPatient(
        patientUid: targetUid,
        title: 'تمت مراجعة شكواك',
        body: 'رد الإدارة: $replyText',
        type: 'complaint_update',
      );
    }
  }
}
