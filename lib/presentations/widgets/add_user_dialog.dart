import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tahweela/firebase_options.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'admin';
  String _selectedSpecialty = 'مخ وأعصاب';
  bool _isLoading = false;

  final List<String> _roles = ['admin', 'doctor', 'patient'];
  final List<String> _specialties = [
    'مخ وأعصاب',
    'قلب وأوعية دموية',
    'جراحة عامة',
    'جراحة عظام',
    'أورام',
    'باطنية',
    'أطفال',
    'نساء وتوليد',
    'عيون',
  ];

  final Map<String, String> _roleLabels = {
    'admin': 'مدير النظام',
    'doctor': 'طبيب',
    'patient': 'مريض',
  };

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FirebaseApp? secondaryApp;

    try {
      final nationalID = _idController.text.trim();
      final email =
          '$nationalID@tahweela.com'; // توحيد النطاق مع قاعدة البيانات
      final password = nationalID;

      // إنشاء أو جلب التطبيق الفرعي بأمان دون تكرار في الذاكرة
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (_) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // إنشاء المستخدم عبر نسخة الـ Auth الفرعية لحماية جلسة المدير
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // حفظ البيانات في Firestore الرئيسي للمدير مع إصلاح حقل الهوية ليكون كابيتال
      final userData = {
        'uid': userCredential.user!.uid,
        'nationalID': nationalID, // تم إصلاحها من nationalId إلى nationalID
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        if (_selectedRole == 'doctor') 'specialty': _selectedSpecialty,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // تسجيل خروج الحساب الجديد من التطبيق الفرعي فوراً لتنظيف الذاكرة
      await secondaryAuth.signOut();

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ في النظام';
      if (e.code == 'email-already-in-use') {
        message = 'رقم الهوية مسجل مسبقاً بالنظام';
      } else if (e.code == 'weak-password') {
        message = 'رقم الهوية قصير جداً ككلمة مرور';
      }
      _showError(message);
    } catch (e) {
      _showError('خطأ غير متوقع: ${e.toString()}');
    } finally {
      if (secondaryApp != null && _selectedRole != 'doctor') {
        // لا نحذف التطبيق بالكامل بل نتركه للحركات القادمة لتوفير الموارد
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'تمت إضافة المستخدم بنجاح',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنه الدخول برقم الهوية كاسم مستخدم وكلمة مرور',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFF16A34A)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'إضافة مستخدم جديد',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهوية الوطنية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'يرجى إدخال رقم الهوية'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'يرجى إدخال الاسم الكامل'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'يرجى إدخال رقم الهاتف'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'صلاحية الحساب (الدور)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: _roles
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(_roleLabels[r]!),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                if (_selectedRole == 'doctor') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: const InputDecoration(
                      labelText: 'التخصص الطبي',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: _specialties
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSpecialty = v!),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'إضافة المستخدم',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'admin';
  String _selectedSpecialty = 'مخ وأعصاب';
  bool _isLoading = false;

  final List<String> _roles = ['admin', 'doctor', 'patient'];
  final List<String> _specialties = [
    'مخ وأعصاب',
    'جراحة عامة',
    'جراحة عظام',
    'أورام',
    'باطنية',
  ];

  final Map<String, String> _roleLabels = {
    'admin': 'مدير النظام',
    'doctor': 'طبيب',
    'patient': 'مريض',
  };

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = '${_idController.text.trim()}@app.com';
      final password = _idController.text.trim();

      // 1. إنشاء حساب بـ Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. حفظ البيانات بـ Firestore
      final userData = {
        'uid': userCredential.user!.uid,
        'nationalId': _idController.text.trim(),
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        if (_selectedRole == 'doctor') 'specialty': _selectedSpecialty,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ';
      if (e.code == 'email-already-in-use') {
        message = 'رقم الهوية مسجل مسبقاً';
      }
      _showError(message);
    } catch (e) {
      _showError('حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'تمت إضافة المستخدم بنجاح',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'يمكنه تسجيل الدخول باسم المستخدم وكلمة المرور',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'إضافة مستخدم جديد',
        textAlign: TextAlign.right,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رقم الهوية
              TextFormField(
                controller: _idController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'رقم الهوية',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'أدخل رقم الهوية' : null,
              ),
              const SizedBox(height: 12),

              // الاسم الكامل
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'أدخل الاسم' : null,
              ),
              const SizedBox(height: 12),

              // رقم الهاتف
              TextFormField(
                controller: _phoneController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'أدخل رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),

              // الدور
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'الدور',
                  border: OutlineInputBorder(),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(_roleLabels[r]!),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),

              // التخصص (يظهر فقط لو الدور طبيب)
              if (_selectedRole == 'doctor') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: const InputDecoration(
                    labelText: 'التخصص',
                    border: OutlineInputBorder(),
                  ),
                  items: _specialties
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSpecialty = v!),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('إضافة', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}*/
