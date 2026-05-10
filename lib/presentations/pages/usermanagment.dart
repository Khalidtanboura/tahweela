import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';
import 'package:tahweela/presentations/widgets/card.dart';
import 'package:tahweela/presentations/widgets/dropdown_menu.dart';
import 'package:tahweela/presentations/widgets/textfield.dart';

class UserManagment extends StatefulWidget {
  const UserManagment({super.key});

  @override
  State<UserManagment> createState() => _UserManagmentState();
}

class _UserManagmentState extends State<UserManagment> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedValue;
  String? _selectedValue2;
  bool isVisablity = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              // 1. الحاوية العلوية مع التدرج اللوني (Gradient)
              secoundAppbarCard(
                title: 'ادارة المستخدمين ',
                icon1: Icons.reply,
                context: context,
              ),
              const SizedBox(height: 22),

              // 2. قائمة المستخدمين
              Expanded(
                child: ListView(
                  children: [
                    _buildUserCard('أحمد المشرف', 'مدير النظام'),
                    _buildUserCard('د. فهد المراجع', 'طبيب مراجع'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Form(
        key: _formKey,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Color(0xffD5D5D5),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'إضافة مستخدم جديد',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        textFiledWithLable(
                          hint: 'رقم الهوية',
                          lable: 'أدخل رقم الهوية',
                        ),
                        textFiledWithLable(
                          hint: 'الاسم الكامل',
                          lable: 'الاسم',
                          isReadonly: true,
                        ),
                        textFiledWithLable(
                          hint: 'رقم الهاتف',
                          lable: 'أدخل رقم الهاتف',
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            'الدور',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        customDropdown(
                          hint: 'مدير النظام',
                          items: ['مدير النظام', 'طبيب'],
                          selectedValue: _selectedValue,
                          onChanged: (value) {
                            setState(() {
                              if (value == 'طبيب') {
                                isVisablity = true;
                              } else {
                                isVisablity = false;
                              }
                              _selectedValue = value;
                            });
                          },
                        ),

                        Visibility(
                          visible: isVisablity,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 5,
                                ),
                                child: Text(
                                  'تخصص الطبيب',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              customDropdown(
                                hint: 'مدير النظام',
                                items: ['مخ وأعصاب', 'قلب'],
                                selectedValue: _selectedValue2,
                                // isEnabled: false,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedValue2 = value;
                                    print(
                                      '------------------------------$value',
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 22),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'إلغاء',
                                  style: TextStyle(color: Color(0xFF1B9E4F)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: customButton(
                                text: 'إضافة',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('نجحت إضافة المستخدم'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// دالة بناء بطاقة المستخدم (User Card)
Widget _buildUserCard(String name, String role) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE0E5EC)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end, // محاذاة النص لليمين
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A), // لون نص غامق
          ),
        ),
        const SizedBox(height: 5),
        Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    ),
  );
}
