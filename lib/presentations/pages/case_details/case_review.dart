import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';

import '../../widgets/card.dart';
import '../../widgets/container.dart';

class CaseReview extends StatelessWidget {
  const CaseReview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // Header
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'تفاصيل الحالة',
                context: context,
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    // ID Card (Blue Border)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFFADCFFF)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "TH-2026-00008",
                            style: TextStyle(
                              color: Color(0xFF2D7FF9),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "المتوسط 65 / 100 • 2/3 أطباء",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Case Files Section
                    customSectionContainer(
                      title: "ملفات الحالة",

                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "تقرير_طبي.pdf",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "PDF • 1.2 MB",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          customMiniButton(
                            "تنزيل",
                            const Color(0xFFE8F5E9),
                            Colors.green,
                          ),
                          const SizedBox(width: 8),
                          customMiniButton(
                            "فتح",
                            const Color(0xFFE3F2FD),
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Medical Evaluation Section
                    customSectionContainer(
                      title: "أسئلة التقييم الطبي",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ما درجة انتشار المرض في الجسم؟",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              "خطيرة جداً — 10/10",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Bottom Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: customActionButton(
                            "رفض",
                            const Color(0xFFE32E2E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: customActionButton(
                            "اعادة نظر",
                            const Color(0xFFF0D678),
                            textColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: customActionButton(
                            "قبول",
                            const Color(0xFF27AE60),
                          ),
                        ),
                      ],
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
