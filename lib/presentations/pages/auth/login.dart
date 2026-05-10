import 'package:flutter/material.dart';
import 'package:tahweela/core/theme.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';
import 'package:tahweela/presentations/widgets/textfield.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
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
                    loginTextFiled(hint: 'رقم الهوية الوطنية'),
                    const SizedBox(height: 15),
                    // حقل كلمة المرور
                    loginTextFiled(hint: 'كلمة المرور', isPassword: true),
                    const SizedBox(height: 30),

                    // زر تسجيل الدخول
                  ],
                ),
              ),
              customReplacementButton(
                context: context,
                nextScreen: 'usermanagment',
                text: 'تسجيل الدخول',
              ),

              const SizedBox(height: 30),

              // العنصر السفلي الباهت (كما في الصورة)
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FA),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
