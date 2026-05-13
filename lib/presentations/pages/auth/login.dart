import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/core/theme.dart';
import 'package:tahweela/presentations/widgets/textfield.dart';
import 'package:tahweela/providers/auth_provider.dart';


class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
    final loginStat = ref.watch(loginControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                // color: Color(0xffDCFCE7),
                margin: EdgeInsets.only(top: 54),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE1F9EB),
                ),
                child: Icon(
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
                    // حقل رقم الهوية
                    loginTextFiled(
                      hint: 'رقم الهوية الوطنية',
                      controller: _idController,
                    ),
                    const SizedBox(height: 15),
                    // حقل كلمة المرور
                    loginTextFiled(
                      hint: 'كلمة المرور',
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 30),

                    // زر تسجيل الدخول
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loginStat.isLoading
                      ? null // تعطيل الزر أثناء التحقق
                      : () async {
                          // التحقق البسيط من أن الحقول ليست فارغة قبل مراسلة فايربيس
                          if (_idController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            ref
                                .read(loginControllerProvider.notifier)
                                .login(
                                  _idController.text,
                                  _passwordController.text,
                                );
                          } else {
                            // رسالة تنبيه إذا كانت الحقول فارغة
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "الرجاء إدخال رقم الهوية وكلمة المرور",
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              ?loginStat.isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    )
                  : null,
              // العنصر السفلي الباهت (كما في الصورة)
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
                      // هنا ستظهر رسالة "كلمة المرور غير صحيحة" مثلاً
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
    );
  }
}
