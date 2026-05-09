import 'package:flutter/material.dart';

import '../widgets/card.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // Header Section
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'الاشعارات',
                context: context,
              ),
              const SizedBox(height: 40),

              // Profile Image / Initial (الدائرة الخضراء الفاتحة)
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFE1F9E9,
                  ), // اللون الأخضر الفاتح جداً من الصورة
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'م',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Info Fields (رقم الهوية ورقم الجوال)
              Column(
                children: [
                  _buildProfileInfoField("رقم الهوية"),
                  const SizedBox(height: 20),
                  _buildProfileInfoField("رقم الجوال"),
                ],
              ),

              const Spacer(),

              // Logout Button (زر تسجيل الخروج)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // منطق تسجيل الخروج
                },
                child: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget مساعد لبناء حقول المعلومات البيضاء
  Widget _buildProfileInfoField(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
