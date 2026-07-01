import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/repositories/complaints_repository.dart';

// تأكد من استيراد الـ Provider الخاص بالإشعارات وليس فقط الـ Repository
import 'package:tahweela/providers/notifications_provider.dart';

class ComplaintNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {
    return;
  }

  // ❌ تم حذف السطر الخاطئ من هنا

  Future<bool> sendComplaints(String complaintText) async {
    state = const AsyncLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;

      // الحل هنا: فحص التأكد من وجود مستخدم
      if (user == null) {
        throw Exception("يجب تسجيل الدخول لإرسال شكوى");
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // إزالة الـ ! هنا
          .get();

      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'مجهول';
      final userRole = userData['role'] ?? 'patient';

      final complaintDoc = await FirebaseFirestore.instance
          .collection('complaints')
          .add({
            'text': complaintText.trim(),
            'userId': user.uid,
            'userName': userName,
            'userRole': userRole,
            'status': 'pending',
            'replyText': '',
            'createdAt': FieldValue.serverTimestamp(),
          });

      // ✅ الحل: جلب مستودع الإشعارات باستخدام ref.read المتاح محلياً
      final notificationsRepo = ref.read(notificationsRepositoryProvider);

      await notificationsRepo.sendNotificationToAdmin(
        title: 'شكوى جديدة في النظام ⚠️',
        body: 'قام $userName بتقديم شكوى بخصوص: $complaintText',
        type: 'complaint_update',
        relatedId: complaintDoc.id,
        routeName: 'complaintsView',
      );

      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}

// مزود لجلب إجمالي عدد الشكاوى في النظام بالوقت الفعلي
final totalComplaintsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('complaints')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// مزود لجلب عدد الشكاوى "قيد الانتظار" فقط بالوقت الفعلي
final pendingComplaintsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('complaints')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// مزود ذكي يستقبل الـ userId ويعيد فقط الشكاوي الخاصة بهذا المستخدم
final personalComplaintsProvider = StreamProvider.family
    .autoDispose<List<Map<String, dynamic>>, String>((ref, userId) {
      return FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    });

final complaintProvider =
    AsyncNotifierProvider.autoDispose<ComplaintNotifier, void>(() {
      return ComplaintNotifier();
    });

// مزود لجلب شكاوى المستخدم الحالي (سواء كان طبيباً أو مريضاً)
final myComplaintsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final user = FirebaseAuth.instance.currentUser;

      // الحل: إذا كان المستخدم فارغاً، نرجع Stream فارغاً فوراً
      if (user == null) return const Stream.empty();

      return FirebaseFirestore.instance
          .collection('complaints')
          .where('userId', isEqualTo: user.uid) // ✅ بدون علامة !
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    });

final complaintsRepositoryProvider = Provider<ComplaintsRepository>((ref) {
  // جلب نسخة من مستودع الإشعارات عبر Riverpod
  final notificationsRepo = ref.watch(notificationsRepositoryProvider);

  // تمريرها مباشرة لمستودع الشكاوى
  return ComplaintsRepository(notificationsRepo: notificationsRepo);
});
