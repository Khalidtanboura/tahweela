import 'package:flutter/material.dart';

import '../../widgets/card.dart';

class CaseDetailsDoctor extends StatelessWidget {
  const CaseDetailsDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // Header Section
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'حالاتي',
                context: context,
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 25),

                        // Appeal Text Field (نص إعادة النظر)
                        _buildLabel("نص اعادة النظر"),
                        _buildTextArea(
                          hint:
                              "الرجاء ارسال صورة اشعة جديدة ...\nالرجاء ارفاق ملف يظهر التفاصيل...",
                          height: 150,
                        ),

                        const SizedBox(height: 20),

                        // Doctor Response Field (رد الطبيب)
                        _buildLabel("رد الطبيب"),
                        _buildTextArea(hint: "", height: 80),

                        const SizedBox(height: 20),

                        // Choose File Button (اختيار ملف من الجهاز)
                        Center(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF27AE60)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "اختيار ملف من الجهاز",
                              style: TextStyle(
                                color: Color(0xFF27AE60),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // File Preview (معاينة الملف المرفق)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F9),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.shade50),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "PDF • 1.2 MB",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "تقرير_جديد.pdf",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Send Button (زر ارسال)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27AE60),
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "ارسال",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// Widget مساعد للعناوين
Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0, right: 5),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

// Widget مساعد لصناديق النصوص
Widget _buildTextArea({required String hint, required double height}) {
  return Container(
    height: height,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: TextField(
      maxLines: null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: InputBorder.none,
      ),
    ),
  );
}
