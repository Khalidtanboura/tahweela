import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';

import '../../widgets/card.dart';

class CaseAdmin extends StatelessWidget {
  const CaseAdmin({super.key});

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
                title: 'تفاصيل الحالة',
                context: context,
              ),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          SizedBox(height: 22),
                          // 3. Action Button (اعتماد الحالة)
                          customButton(
                            text: 'اعتماد الحالة وتحويلها للمراجعة الطبية',
                            onTap: () {},
                          ),

                          const SizedBox(height: 25),

                          // 4. Attachments Section (المرفقات الطبية)
                          sectionCard(
                            title: "المرفقات الطبية",
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4F9),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "تقرير_طبي.pdf",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "محفوظ محلياً • 1.2 MB • PDF",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red.shade400,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 5. Notes Section (نص الملاحظات)
                          sectionCard(
                            title: "نص الملاحظات",

                            child: TextField(maxLines: 4),
                          ),
                        ],
                      ),
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
