import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tahweela/data/models/public_users.dart';
import 'package:tahweela/data/repositories/auth_repository.dart';
import 'package:tahweela/data/repositories/public_users_repository.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authRepository = AuthRepository();
  final _publicUsersRepository = PublicUsersRepository();

  String _selectedRole = 'patient';
  String _selectedSpecialty = 'مخ وأعصاب';
  PublicUserModel? _selectedPublicUser;
  bool _isLoading = false;
  bool _isSearching = false;

  static const _roles = ['patient', 'doctor', 'admin'];
  static const _specialties = [
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

  static const _roleLabels = {
    'admin': 'مدير النظام',
    'doctor': 'طبيب',
    'patient': 'مريض',
  };

  @override
  void dispose() {
    _idController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchPublicUser() async {
    final nationalId = _idController.text.trim();
    if (nationalId.isEmpty) {
      _showError('يرجى إدخال رقم الهوية أولا');
      return;
    }

    setState(() => _isSearching = true);
    try {
      final publicUser = await _publicUsersRepository.findByNationalId(
        nationalId,
      );

      if (publicUser == null) {
        setState(() => _selectedPublicUser = null);
        _showError('لم يتم العثور على هذا الشخص في قاعدة البيانات العامة');
        return;
      }

      if (_shouldBlockLinkedPublicUser(publicUser)) {
        setState(() => _selectedPublicUser = null);
        _showError('هذا الشخص مربوط بحساب داخل التطبيق مسبقا');
        return;
      }

      setState(() => _selectedPublicUser = publicUser);
    } catch (_) {
      _showError('تعذر البحث في قاعدة البيانات العامة');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  bool _shouldBlockLinkedPublicUser(PublicUserModel publicUser) {
    return false;
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedId = _selectedPublicUser?.nationalId;
    if (_selectedPublicUser == null ||
        selectedId != _idController.text.trim()) {
      await _searchPublicUser();
    }
    if (_selectedPublicUser == null ||
        _selectedPublicUser!.nationalId != _idController.text.trim()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepository.createLinkedUserFromPublicUser(
        publicUser: _selectedPublicUser!,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        specialty: _selectedRole == 'doctor' ? _selectedSpecialty : null,
        password: _idController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (error) {
      _showError(_authErrorMessage(error));
    } catch (_) {
      _showError('حدث خطأ أثناء إنشاء الحساب وربطه بقاعدة البيانات العامة');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    final details = error.message?.trim() ?? '';
    final lowerDetails = details.toLowerCase();

    if (error.code == 'operation-not-allowed' ||
        lowerDetails.contains('password_login_disabled') ||
        lowerDetails.contains('configuration_not_found')) {
      return 'لم يتم إنشاء المستخدم في Firebase Authentication لأن تسجيل الدخول بالبريد وكلمة المرور غير مفعّل';
    }

    if (lowerDetails.contains('connection closed') ||
        lowerDetails.contains('internal error')) {
      return 'لم يتم إنشاء المستخدم في Firebase Authentication بسبب مشكلة اتصال أو إعدادات Firebase/Recaptcha';
    }

    switch (error.code) {
      case 'email-already-in-use':
        return 'هذا المستخدم موجود مسبقاً في Firebase Authentication';
      case 'invalid-email':
        return 'تعذر إنشاء الحساب لأن البريد المولّد من رقم الهوية غير صالح';
      case 'weak-password':
        return 'تعذر إنشاء الحساب لأن كلمة المرور ضعيفة جداً، يجب أن تكون 6 خانات على الأقل';
      case 'network-request-failed':
        return 'تعذر إنشاء المستخدم في Firebase Authentication، تحقق من اتصال الإنترنت';
      default:
        if (details.isNotEmpty) {
          return 'فشل إنشاء المستخدم في Firebase Authentication. رمز الخطأ: ${error.code}. التفاصيل: $details';
        }
        return 'فشل إنشاء المستخدم في Firebase Authentication. رمز الخطأ: ${error.code}';
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 56),
            SizedBox(height: 16),
            Text(
              'تمت إضافة المستخدم بنجاح',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'يمكنه الدخول برقم الهوية كاسم مستخدم وكلمة مرور',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنا'),
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
                    border: OutlineInputBorder(),
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
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onChanged: (_) =>
                            setState(() => _selectedPublicUser = null),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'يرجى إدخال رقم الهوية'
                            : null,
                      ),
                    ),
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
                ),
                if (publicUser != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(label: 'الاسم', value: publicUser.fullName),
                        _InfoChip(label: 'العمر', value: '${publicUser.age}'),
                        _InfoChip(label: 'الجنس', value: publicUser.gender),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
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
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
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
                : const Text('إضافة المستخدم'),
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
