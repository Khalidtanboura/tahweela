import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedValue;
  String? _selectedValue2;
  bool isVisablity = false;
  bool _isLoading = false;

  String _getRoleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'طبيب';
      case 'patient':
        return 'مريض';
      case 'admin':
      default:
        return 'مدير النظام';
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              secoundAppbarCard(
                title: 'ادارة المستخدمين ',
                icon1: Icons.reply,
                context: context,
              ),
              const SizedBox(height: 22),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF16A34A),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا يوجد مستخدمون',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user =
                            users[index].data() as Map<String, dynamic>;
                        final name = user['name'] ?? 'بدون اسم';
                        final role = _getRoleLabel(user['role'] ?? 'admin');
                        final specialty = user['specialty'] ?? '';
                        return _buildUserCard(
                          name,
                          specialty.isNotEmpty ? '$role • $specialty' : role,
                        );
                      },
                    );
                  },
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
            _idController.clear();
            _nameController.clear();
            _phoneController.clear();
            setState(() {
              _selectedValue = null;
              _selectedValue2 = null;
              isVisablity = false;
            });

            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return StatefulBuilder(
                  builder: (dialogContext, setStateDialog) {
                    return Dialog(
                      backgroundColor: Color(0xffD5D5D5),
                      child: SingleChildScrollView(
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
                                controller: _idController,
                              ),
                              textFiledWithLable(
                                hint: 'الاسم الكامل',
                                lable: 'الاسم',
                                controller: _nameController,
                              ),
                              textFiledWithLable(
                                hint: 'رقم الهاتف',
                                lable: 'أدخل رقم الهاتف',
                                controller: _phoneController,
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 5,
                                ),
                                child: const Text(
                                  'الدور',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              customDropdown(
                                hint: 'مدير النظام',
                                items: ['مدير النظام', 'طبيب', 'مريض'],
                                selectedValue: _selectedValue,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    _selectedValue = value;
                                    isVisablity = value == 'طبيب';
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
                                      child: const Text(
                                        'تخصص الطبيب',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    customDropdown(
                                      hint: 'اختر التخصص',
                                      items: [
                                        'مخ وأعصاب',
                                        'قلب وأوعية دموية',
                                        'جراحة عامة',
                                        'جراحة عظام',
                                        'أورام',
                                        'باطنية',
                                        'أطفال',
                                        'نساء وتوليد',
                                        'عيون',
                                        'أنف وأذن وحنجرة',
                                        'جلدية',
                                        'طب نفسي',
                                        'طوارئ',
                                      ],
                                      selectedValue: _selectedValue2,
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          _selectedValue2 = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: const Text(
                                        'إلغاء',
                                        style: TextStyle(
                                          color: Color(0xFF1B9E4F),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF16A34A),
                                            ),
                                          )
                                        : customButton(
                                            text: 'إضافة',
                                            onTap: () async {
                                              if (_idController.text
                                                      .trim()
                                                      .isEmpty ||
                                                  _nameController.text
                                                      .trim()
                                                      .isEmpty ||
                                                  _phoneController.text
                                                      .trim()
                                                      .isEmpty ||
                                                  _selectedValue == null) {
                                                ScaffoldMessenger.of(
                                                  dialogContext,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'يرجى تعبئة جميع الحقول',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }

                                              setStateDialog(
                                                () => _isLoading = true,
                                              );

                                              try {
                                                final email =
                                                    '${_idController.text.trim()}@tahweela.com';
                                                final password = _idController
                                                    .text
                                                    .trim();

                                                final userCredential =
                                                    await FirebaseAuth.instance
                                                        .createUserWithEmailAndPassword(
                                                          email: email,
                                                          password: password,
                                                        );

                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(
                                                      userCredential.user!.uid,
                                                    )
                                                    .set({
                                                      'uid': userCredential
                                                          .user!
                                                          .uid,
                                                      'nationalId':
                                                          _idController.text
                                                              .trim(),
                                                      'name': _nameController
                                                          .text
                                                          .trim(),
                                                      'phone': _phoneController
                                                          .text
                                                          .trim(),
                                                      'role':
                                                          _selectedValue ==
                                                              'طبيب'
                                                          ? 'doctor'
                                                          : _selectedValue ==
                                                                'مريض'
                                                          ? 'patient'
                                                          : 'admin',
                                                      if (_selectedValue ==
                                                          'طبيب')
                                                        'specialty':
                                                            _selectedValue2,
                                                      'createdAt':
                                                          FieldValue.serverTimestamp(),
                                                      'email':
                                                          '${_idController.text.trim()}@tahweela.com',
                                                    });

                                                setStateDialog(
                                                  () => _isLoading = false,
                                                );
                                                Navigator.pop(dialogContext);

                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                16,
                                                              ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                color: Color(
                                                                  0xFF16A34A,
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                          child: const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 32,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        const Text(
                                                          'تمت إضافة المستخدم بنجاح',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        const Text(
                                                          'يمكنه تسجيل الدخول باسم المستخدم وكلمة المرور',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'حسناً',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } on FirebaseAuthException catch (
                                                e
                                              ) {
                                                setStateDialog(
                                                  () => _isLoading = false,
                                                );
                                                ScaffoldMessenger.of(
                                                  dialogContext,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.code ==
                                                              'email-already-in-use'
                                                          ? 'رقم الهوية مسجل مسبقاً'
                                                          : 'حدث خطأ: ${e.message}',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              } catch (e) {
                                                setStateDialog(
                                                  () => _isLoading = false,
                                                );
                                                ScaffoldMessenger.of(
                                                  dialogContext,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'حدث خطأ غير متوقع',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 5),
        Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    ),
  );
}
