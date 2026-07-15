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

  // داخل كلاس ComplaintNotifier في ملف complanits_provider.dart

  Future<bool> sendComplaints(String complaintText) async {
    state = const AsyncLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("يجب تسجيل الدخول لإرسال شكوى");
      }

      // جلب بيانات المستخدم الحالي لتضمينها مع الشكوى
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? 'مجهول';
      final userRole = userData['role'] ?? 'patient';

      // 1. تجهيز بيانات الشكوى في الخريطة (Map)
      final complaintData = {
        'userId': user.uid,
        'userName': userName,
        'userRole': userRole,
        'complaintText': complaintText,
        'createdAt': FieldValue.serverTimestamp(), // تسجيل وقت السيرفر بدقة
      };

      // ==================== [بداية كود الـ Batch الجديد] ====================
      final batch = FirebaseFirestore.instance.batch();

      // أ. مرجع الشكوى الجديدة (إنشاء مستند جديد والحصول على الـ ID الخاص به تلقائياً)
      final complaintRef = FirebaseFirestore.instance
          .collection('complaints')
          .doc();
      batch.set(complaintRef, complaintData);

      // ب. مرجع مستند العداد وزيادته بمقدار 1
      final counterRef = FirebaseFirestore.instance
          .collection('metadata')
          .doc('complaints_counter');
      batch.set(counterRef, {
        'count': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // ج. تنفيذ عمليتي (حفظ الشكوى + زيادة العداد) دفعة واحدة في السيرفر
      await batch.commit();
      // ==================== [نهاية كود الـ Batch الجديد] ====================

      state = const AsyncData<void>(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

/*// مزود لجلب إجمالي عدد الشكاوى في النظام بالوقت الفعلي
final totalComplaintsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('complaints')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});*/
final totalComplaintsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('metadata')
      .doc('complaints_counter') // مستند منفصل يحمل العداد فقط
      .snapshots()
      .map((snapshot) {
        final data = snapshot.data();
        return (data?['count'] as num?)?.toInt() ??
            0; // ✅ عملية قراءة واحدة فقط دائماً مهما بلغ حجم البيانات!
      });
});
/*final totalComplaintsCountOnceProvider = FutureProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('complaints')
      .snapshots()
      .map((snapshot) => snapshot.docs.length)
      .first;
});*/
final totalComplaintsCountOnceProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final query = FirebaseFirestore.instance.collection('complaints');
  final aggregateSnapshot = await query
      .count()
      .get(); // ✅ حساب العداد على الخادم مباشرة دون تحميل أي مستند
  return aggregateSnapshot.count ?? 0;
});
// مزود لجلب عدد الشكاوى "قيد الانتظار" فقط بالوقت الفعلي
final pendingComplaintsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('complaints')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final pendingComplaintsCountOnceProvider = FutureProvider.autoDispose<int>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('complaints')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.length)
      .first;
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
