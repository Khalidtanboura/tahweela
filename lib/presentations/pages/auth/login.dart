import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/core/theme.dart';
import 'package:tahweela/presentations/widgets/textfield.dart';
import 'package:tahweela/providers/login_provider.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final loginStat = ref.watch(loginControllerProvider);
    ref.listen<AsyncValue<void>>(loginControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString(), textAlign: TextAlign.right),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 54),
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE1F9EB),
                  ),
                  child: const Icon(
                    Icons.medical_services_sharp,
                    size: 60,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'تحويلة',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B9E4F),
                  ),
                ),
                const SizedBox(height: 40),

                // بطاقة تسجيل الدخول
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      loginTextFiled(
                        hint: 'رقم الهوية الوطنية',
                        controller: _idController,
                      ),
                      const SizedBox(height: 15),
                      loginTextFiled(
                        hint: 'كلمة المرور',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                        isPassword: _obscurePassword,
                        controller: _passwordController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // زر تسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (loginStat.isLoading) return;
                      if (_formKey.currentState!.validate()) {
                        // استدعاء دالة تسجيل الدخول المعتمدة على رقم الهوية الوطنية
                        ref
                            .read(loginControllerProvider.notifier)
                            .loginWithNationalID(
                              _idController.text.trim(),
                              _passwordController.text.trim(),
                            );
                      }
                    },
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ تصحيح: إزالة الـ ? الغلط واستبداله بـ if صحيح
                if (loginStat.isLoading)
                  const CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),

                const SizedBox(height: 20),

                // الصندوق السفلي
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: loginStat.maybeWhen(
                      error: (error, _) => Text(
                        error.toString(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      orElse: () => const Text("الرجاء إدخال بياناتك"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
