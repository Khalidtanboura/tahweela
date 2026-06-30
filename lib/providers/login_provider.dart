import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
      return LoginController();
    });

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController() : super(const AsyncData<void>(null));

  void reset() {
    state = const AsyncData<void>(null);
  }

  Future<void> loginWithNationalID(String nationalID, String password) async {
    state = const AsyncLoading();

    try {
      final normalizedNationalID = _normalizeNationalId(nationalID);
      final email = '$normalizedNationalID@tahweela.com';

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _normalizePassword(password),
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        await FirebaseAuth.instance.signOut();
        state = AsyncValue.error(
          'تعذر قراءة بيانات المستخدم، حاول مرة أخرى',
          StackTrace.current,
        );
        return;
      }

      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        final linkedUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('nationalID', isEqualTo: normalizedNationalID)
            .limit(1)
            .get();

        if (linkedUserDoc.docs.isEmpty) {
          await FirebaseAuth.instance.signOut();
          state = AsyncValue.error(
            'لا توجد بيانات لهذا المستخدم في النظام',
            StackTrace.current,
          );
          return;
        }

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          ...linkedUserDoc.docs.first.data(),
          'uid': uid,
          'email': email,
          'nationalID': normalizedNationalID,
        });

        if (linkedUserDoc.docs.first.id != uid) {
          await linkedUserDoc.docs.first.reference.delete();
        }

        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
      }

      final role = userDoc.data()?['role'];
      if (role != 'admin' && role != 'doctor' && role != 'patient') {
        await FirebaseAuth.instance.signOut();
        state = AsyncValue.error(
          'نوع الحساب غير معروف، يرجى مراجعة مدير النظام',
          StackTrace.current,
        );
        return;
      }

      state = const AsyncData<void>(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_authErrorMessage(e), StackTrace.current);
    } catch (_) {
      state = AsyncValue.error(
        'حدث خطأ غير متوقع، حاول مرة أخرى',
        StackTrace.current,
      );
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    final details = error.message?.trim() ?? '';
    final lowerDetails = details.toLowerCase();

    if (error.code == 'operation-not-allowed' ||
        lowerDetails.contains('password_login_disabled') ||
        lowerDetails.contains('configuration_not_found')) {
      return 'تسجيل الدخول بالبريد وكلمة المرور غير مفعّل في Firebase Authentication';
    }

    if (lowerDetails.contains('connection closed') ||
        lowerDetails.contains('internal error')) {
      return 'تعذر الاتصال بخدمة Firebase Authentication. تحقق من الإنترنت وإعدادات Firebase للتطبيق';
    }

    switch (error.code) {
      case 'network-request-failed':
        return 'يرجى التحقق من اتصال الإنترنت';
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
        return 'رقم الهوية أو كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'تمت محاولات كثيرة، انتظر قليلاً ثم حاول مرة أخرى';
      default:
        if (details.isNotEmpty) {
          return 'فشل تسجيل الدخول. رمز الخطأ: ${error.code}. التفاصيل: $details';
        }
        return 'فشل تسجيل الدخول. رمز الخطأ: ${error.code}';
    }
  }

  String _normalizeNationalId(String value) {
    return value.trim().replaceAll(RegExp(r'[\s-]+'), '').replaceAllMapped(
      RegExp(r'[٠-٩۰-۹]'),
      (match) {
        const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
        const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
        final digit = match.group(0)!;
        final arabicIndex = arabicDigits.indexOf(digit);
        if (arabicIndex != -1) return arabicIndex.toString();
        return persianDigits.indexOf(digit).toString();
      },
    );
  }

  String _normalizePassword(String value) {
    return _normalizeNationalId(value);
  }
}
