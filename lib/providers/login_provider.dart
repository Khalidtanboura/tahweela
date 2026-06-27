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
      final trimmedNationalID = nationalID.trim();
      final email = '$trimmedNationalID@tahweela.com';

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
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

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        await FirebaseAuth.instance.signOut();
        state = AsyncValue.error(
          'لا توجد بيانات لهذا المستخدم في النظام',
          StackTrace.current,
        );
        return;
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
    } catch (e) {
      state = AsyncValue.error(
        'حدث خطأ غير متوقع، حاول مرة أخرى',
        StackTrace.current,
      );
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return 'يرجى التحقق من اتصال الإنترنت';
      case 'invalid-credential':
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
        return 'رقم الهوية أو كلمة المرور غير صحيحة';
      case 'too-many-requests':
        return 'تمت محاولات كثيرة، انتظر قليلاً ثم حاول مرة أخرى';
      default:
        return 'فشل تسجيل الدخول، تحقق من البيانات وحاول مرة أخرى';
    }
  }
}
