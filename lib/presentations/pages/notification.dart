import 'package:flutter/material.dart';

import '../widgets/card.dart';

class MyNotification extends StatelessWidget {
  const MyNotification({super.key});

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
              const SizedBox(height: 20),

              // Notifications List - قائمة الإشعارات
              Expanded(
                child: ListView(
                  // padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    NotificationCard(
                      title: "تم إنشاء حسابك واعتماد الحالة",
                      subtitle: "اسم المستخدم: رقم الهوية",
                    ),
                    NotificationCard(
                      title: "حالة جديدة للمراجعة الطبية",
                      subtitle: "تمت إحالة الحالة TH-2026-00008 إليك",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const NotificationCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          25,
        ), // حواف دائرية كبيرة كما في الصورة
        border: Border.all(
          color: const Color(0xFFE3F2FD),
        ), // إطار أزرق فاتح جداً
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // محاذاة النص لليمين
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
