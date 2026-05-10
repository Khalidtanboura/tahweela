import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';
import 'package:tahweela/presentations/widgets/card.dart';
import 'package:tahweela/presentations/widgets/text.dart';

class ComplaintsState extends StatefulWidget {
  const ComplaintsState({super.key});

  @override
  State<ComplaintsState> createState() => _ComplaintsStateState();
}

class _ComplaintsStateState extends State<ComplaintsState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              // Header Section
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'حالة الشكوى ',
                context: context,
              ),

              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    // Blue Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "محمد المريض",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
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
                              ),
                            ],
                          ),
                          const Text(
                            "جراحة عظام",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const Text(
                            "التاريخ : 15/05/2050",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Status Badge
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Complaint Text Section
                    mySectionTitle("نص الشكوى"),
                    myContentBox(
                      "اريد اعادة تقييم ...\nاشعر ان الاوراق ناقصة اثرت على التقييم ...",
                    ),

                    const SizedBox(height: 20),

                    // Reply Section
                    mySectionTitle("الرد على الشكوى"),
                    myContentBox(
                      "التوجه للمستشفى - الطبيب المعالج\nلاعادة النظر في القضية",
                      textColor: Colors.grey,
                    ),

                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: myOutlineButton("رفض شكوى", Colors.red),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: myOutlineButton(
                            "قبول شكوى",
                            Colors.green,
                          ), // ملاحظة: النص في الصورة كان مكرر "رفض"، قمت بتعديله للمنطق
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
