import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

// هذا المزود يدير حالة زر تسجيل الدخول (تحميل، نجاح، خطأ)
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
      return LoginController();
    });

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController() : super(const AsyncData<void>(null));

  Future<void> loginWithNationalID(String nationalID, String password) async {
    state = const AsyncLoading();

    try {
      final email = '${nationalID.trim()}@tahweela.com';

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      // إذا نجحنا نضع الحالة نجاح
      state = const AsyncData<void>(null);
    } on FirebaseAuthException catch (e) {
      print("خطأ Firebase الفعلي: ${e.code}");
      String errorMessage = 'رقم الهوية غير مسجل بالنظام أو خطأ في البيانات';
      if (e.code == 'network-request-failed') {
        errorMessage = 'يرجى التحقق من اتصالك بالإنترنت';
      }
      // إرسال الخطأ إلى الواجهة لتنبيه المستخدم
      state = AsyncValue.error(errorMessage, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        'خطأ غير متوقع: ${e.toString()}',
        StackTrace.current,
      );
    }
  }
}
