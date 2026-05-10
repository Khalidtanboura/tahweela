import 'package:flutter/material.dart';

import '../../widgets/card.dart';

class CasePatient extends StatefulWidget {
  const CasePatient({super.key});

  @override
  State<CasePatient> createState() => _CasePatientState();
}

class _CasePatientState extends State<CasePatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // Header Section
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'حالة الشكوى ',
                context: context,
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        "TH-2026-00002",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAA7),
                        // اللون الأصفر الباهت
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        "قيد المراجعة",
                        style: TextStyle(
                          color: Color(0xFFD35400),
                          // لون برتقالي غامق للنص
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "نتيجة المراجعة الطبية",
                      style: TextStyle(
                        // لون برتقالي غامق للنص
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "عدد التقييمات: 2 من 3",
                      style: TextStyle(
                        // لون برتقالي غامق للنص
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      "متوسط النتيجة: 60 / 100",
                      style: TextStyle(
                        // لون برتقالي غامق للنص
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},

                  style: OutlinedButton.styleFrom(
                    // لون النص والأيقونة
                    foregroundColor: Colors.red,
                    // لون الإطار
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: Text('تقديم شكوى'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
