import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tahweela/data/models/public_users.dart';
import 'package:tahweela/data/repositories/public_users_repository.dart';
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
  final _publicUsersRepository = PublicUsersRepository();

  String _selectedRole = 'patient';
  String _selectedSpecialty = 'مخ وأعصاب';
  PublicUserModel? _selectedPublicUser;
  bool _isLoading = false;
  bool _isSearching = false;

  final List<String> _roles = ['patient', 'doctor', 'admin'];
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
    'أنف وأذن وحنجرة',
    'جلدية',
    'طب نفسي',
    'طوارئ',
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

  Future<FirebaseApp> _secondaryApp() async {
    try {
      return Firebase.app('SecondaryApp');
    } catch (_) {
      return Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  Future<void> _searchPublicUser() async {
    final nationalId = _idController.text.trim();
    if (nationalId.isEmpty) {
      _showError('يرجى إدخال رقم الهوية أولاً');
      return;
    }

    setState(() => _isSearching = true);
    try {
      final publicUser = await _publicUsersRepository.findByNationalId(
        nationalId,
      );

      if (publicUser == null) {
        _selectedPublicUser = null;
        _nameController.clear();
        _showError(
          'لم يتم العثور على مريض بهذا الرقم في قاعدة البيانات العامة',
        );
        return;
      }

      if (publicUser.isLinked) {
        _selectedPublicUser = null;
        _nameController.text = publicUser.fullName;
        _showError('هذا المريض مربوط بحساب داخل التطبيق مسبقاً');
        return;
      }

      setState(() {
        _selectedPublicUser = publicUser;
        _nameController.text = publicUser.fullName;
      });
    } catch (e) {
      _showError('تعذر البحث في قاعدة البيانات العامة');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'patient') {
      final searchedId = _selectedPublicUser?.nationalId;
      if (_selectedPublicUser == null ||
          searchedId != _idController.text.trim()) {
        await _searchPublicUser();
      }
      if (_selectedPublicUser == null ||
          _selectedPublicUser!.nationalId != _idController.text.trim()) {
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final nationalId = _idController.text.trim();
      final email = '$nationalId@tahweela.com';
      final secondaryAuth = FirebaseAuth.instanceFor(
        app: await _secondaryApp(),
      );

      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: nationalId,
      );
      final uid = userCredential.user!.uid;

      final userData = {
        'uid': uid,
        'email': email,
        'nationalID': nationalId,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        if (_selectedRole == 'doctor') 'specialty': _selectedSpecialty,
        if (_selectedRole == 'patient') ...{
          'publicUserId': _selectedPublicUser!.publicUserId,
          'gender': _selectedPublicUser!.gender,
          'age': _selectedPublicUser!.age,
        },
      };

      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('users').doc(uid),
        userData,
      );

      if (_selectedRole == 'patient') {
        batch.update(
          FirebaseFirestore.instance
              .collection('public_users')
              .doc(_selectedPublicUser!.documentId),
          {
            'is_linked': true,
            'app_user_uid': uid,
            'linked_at': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
      await secondaryAuth.signOut();

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('رقم الهوية مسجل مسبقاً في النظام');
      } else if (e.code == 'weak-password') {
        _showError('رقم الهوية قصير جداً ككلمة مرور');
      } else {
        _showError(e.message ?? 'حدث خطأ أثناء إنشاء الحساب');
      }
    } catch (e) {
      _showError('حدث خطأ غير متوقع أثناء إضافة المستخدم');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
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
    final publicUser = _selectedPublicUser;

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
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'صلاحية الحساب',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: _roles
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(_roleLabels[role]!),
                        ),
                      )
                      .toList(),
                  onChanged: (role) {
                    if (role == null) return;
                    setState(() {
                      _selectedRole = role;
                      _selectedPublicUser = null;
                      _nameController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهوية الوطنية',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onChanged: (_) {
                          if (_selectedRole == 'patient') {
                            setState(() => _selectedPublicUser = null);
                          }
                        },
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'يرجى إدخال رقم الهوية'
                            : null,
                      ),
                    ),
                    if (_selectedRole == 'patient') ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isSearching ? null : _searchPublicUser,
                          child: _isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                        ),
                      ),
                    ],
                  ],
                ),
                if (publicUser != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(label: 'العمر', value: '${publicUser.age}'),
                        _InfoChip(label: 'الجنس', value: publicUser.gender),
                        _InfoChip(
                          label: 'السجل',
                          value: publicUser.publicUserId,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  readOnly: _selectedRole == 'patient',
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
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
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'يرجى إدخال رقم الهاتف'
                      : null,
                ),
                if (_selectedRole == 'doctor') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecialty,
                    decoration: const InputDecoration(
                      labelText: 'التخصص الطبي',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    items: _specialties
                        .map(
                          (specialty) => DropdownMenuItem(
                            value: specialty,
                            child: Text(specialty),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSpecialty = value);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFFEFF6FF),
      label: Text('$label: $value'),
      side: BorderSide.none,
    );
  }
}
