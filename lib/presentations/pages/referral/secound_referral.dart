import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';

import '../../widgets/card.dart';

class SecondReferral extends StatefulWidget {
  const SecondReferral({super.key});

  @override
  State<SecondReferral> createState() => _SecondReferralState();
}

class _SecondReferralState extends State<SecondReferral> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              appTitleCard(title: 'حالة تحويل جديدة'),
              const SizedBox(height: 22),

              // 2. قائمة المستخدمين
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'أسئلة الحالة المدخلة',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'التقيم : 5/4',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CardQustion(title: 'هل العلاج متوفر داخل القطاع؟'),
                          CardQustion(title: 'هل تحتاج الحالة تحويلة طبية؟'),
                          CardQustion(title: 'ما درجة انتشار المرض في الجسم؟'),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE0E6ED),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ملاحظات",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FB),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFDCE1E8),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,

                      height: 55,
                      child: customButton(
                        text: "إرسال الحالة لاعتماد مدير النظام",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('نجحت إضافة الحالة')),
                          );
                        },
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
