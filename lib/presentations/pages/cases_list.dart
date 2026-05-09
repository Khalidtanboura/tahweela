import 'package:flutter/material.dart';

import '../widgets/card.dart';

class CasesList extends StatelessWidget {
  const CasesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // خلفية رمادية فاتحة جداً
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              // Header السهم والعنوان
              secoundAppbarCard(
                title: 'الحالات',
                icon1: Icons.reply,
                context: context,
              ),

              // خانة البحث الفارغة
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),

              // قائمة الحالات
              Expanded(
                child: ListView(
                  // padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    CaseCard(
                      id: "TH-2026-00008",
                      status: "بانتظار اعتماد المدير",
                      statusColor: Color(0xFFD6E4FF),
                      statusTextColor: Color(0xFF3366FF),
                      specialty: "جراحة عامة",
                      patientName: "",
                    ),
                    CaseCard(
                      id: "TH-2026-00002",
                      status: "قيد المراجعة",
                      statusColor: Color(0xFFFFF4D6),
                      statusTextColor: Color(0xFFB37E00),
                      specialty: "جراحة عظام",
                      patientName: "محمد المريض",
                    ),
                    CaseCard(
                      id: "TH-2026-00002",
                      status: "اعادة نظر",
                      statusColor: Color(0xFFD6FFD8),
                      statusTextColor: Color(0xFF1B5E20),
                      specialty: "جراحة عظام",
                      patientName: "محمد المريض",
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
