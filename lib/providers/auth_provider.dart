import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';

//معرفة حالة المستخدم ودوره اذا كان طبيب او ادمن او مريض
final userRoleProvider = StreamProvider<String?>((ref) async* {
  await Future.delayed(const Duration(seconds: 3));
  final authStream = FirebaseAuth.instance.authStateChanges();

  await for (final user in authStream) {
    if (user == null) {
      yield null;
    } else {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists &&
            doc.data() != null &&
            doc.data()!.containsKey('role')) {
          yield doc.data()!['role'] as String;
        } else {
          yield 'patient';
        }
      } catch (e) {
        print("خطأ في جلب الصلاحيات: $e");
        yield null; // في حالة الخطأ، نخرجه للوجين
      }
    }
  }
});

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
      return LoginController(ref.watch(authProvider));
    });

class LoginController extends StateNotifier<AsyncValue<void>> {
  final FirebaseAuth _auth;

  LoginController(this._auth) : super(const AsyncValue.data(null));

  Future<void> login(String identifier, String password) async {
    state = const AsyncValue.loading(); // تغيير الحالة إلى قيد التحميل

    try {
      // String emailToLogin = identifier;
      // if (!emailToLogin.contains('@')) {
      //   emailToLogin = '$identifier@tahweela.com';
      // }
      await _auth.signInWithEmailAndPassword(
        email: identifier.trim(),
        password: password.trim(),
      );
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      print('==============================================${e.code}');
      String errorMessage = '';
      if (e.code == 'user-not-found') {
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'خطأ في الشبكة';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'بيانات الدخول غير صحيحة (البريد أو كلمة المرور).';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'صيغة البريد/رقم الهوية غير صحيحة.';
      }
      state = AsyncValue.error(errorMessage, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('خطأ في الاتصال بالنظام', StackTrace.current);
    }
  }
}
