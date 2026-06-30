import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tahweela/data/models/public_users.dart';
import 'package:tahweela/data/models/referral_draft.dart';
import 'package:tahweela/data/repositories/public_users_repository.dart';
import 'package:tahweela/presentations/pages/referral/secound_referral.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';

import '../../../core/theme.dart';
import '../../widgets/card.dart';

class NewReferral extends StatefulWidget {
  const NewReferral({super.key});

  @override
  State<NewReferral> createState() => _NewReferralState();
}

class _NewReferralState extends State<NewReferral> {
  final _nationalIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _publicUsersRepository = PublicUsersRepository();

  PublicUserModel? _patient;
  String? _diseaseType;
  List<PlatformFile> _selectedFiles = [];
  bool _isSearching = false;

  static const _diseaseTypes = [
    'القلب',
    'العظام',
    'الدماغ',
    'الأورام',
    'الأطفال',
    'الباطنية',
    'الطوارئ',
  ];

  @override
  void dispose() {
    _nationalIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatient() async {
    final nationalId = _nationalIdController.text.trim();
    if (nationalId.isEmpty) {
      _showSnackBar('يرجى إدخال رقم الهوية أولا');
      return;
    }

    setState(() => _isSearching = true);
    try {
      final patient = await _publicUsersRepository.findByNationalId(nationalId);
      if (patient == null) {
        _clearPatientFields();
        _showSnackBar('لم يتم العثور على مريض بهذا الرقم');
        return;
      }

      setState(() {
        _patient = patient;
        _nameController.text = patient.fullName;
        _ageController.text = patient.age.toString();
      });
    } catch (_) {
      _showSnackBar('تعذر جلب بيانات المريض');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null) return;
    setState(() => _selectedFiles = result.files);
  }

  void _continue() {
    if (_nationalIdController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال رقم الهوية');
      return;
    }
    if (_patient == null) {
      _showSnackBar('يرجى جلب بيانات المريض أولا');
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال رقم الهاتف');
      return;
    }
    if (_diseaseType == null) {
      _showSnackBar('يرجى اختيار نوع المرض');
      return;
    }
    if (_selectedFiles.isEmpty) {
      _showSnackBar('يرجى إرفاق ملف طبي واحد على الأقل');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondReferral(
          draft: ReferralDraft(
            patient: _patient!,
            phone: _phoneController.text.trim(),
            diseaseType: _diseaseType!,
            files: _selectedFiles,
          ),
        ),
      ),
    );
  }

  void _clearPatientFields() {
    setState(() {
      _patient = null;
      _nameController.clear();
      _ageController.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                appTitleCard(title: 'حالة تحويل جديدة'),
                const SizedBox(height: 22),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E6ED)),
                    ),
                    child: ListView(
                      children: [
                        _LabeledField(
                          label: 'رقم الهوية',
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nationalIdController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => _clearPatientFields(),
                                  decoration: const InputDecoration(
                                    hintText: 'ادخل رقم الهوية',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: _isSearching
                                      ? null
                                      : _fetchPatient,
                                  child: _isSearching
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('جلب'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _LabeledField(
                          label: 'الاسم الكامل',
                          child: TextField(
                            controller: _nameController,
                            enabled: false,
                            decoration: const InputDecoration(
                              hintText: 'الاسم كامل',
                            ),
                          ),
                        ),
                        _LabeledField(
                          label: 'ادخل رقم الهاتف',
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'ادخل رقم الهاتف',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _LabeledField(
                                label: 'العمر',
                                child: TextField(
                                  controller: _ageController,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    hintText: 'العمر',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _LabeledField(
                                label: 'نوع المرض',
                                child: DropdownButtonFormField<String>(
                                  initialValue: _diseaseType,
                                  hint: const Text('نوع المرض'),
                                  items: _diseaseTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _diseaseType = value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE0E6ED)),
                          ),
                          child: Column(
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickFiles,
                                icon: const Icon(Icons.attach_file),
                                label: const Text('اختيار ملف من الجهاز'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF23A455),
                                  side: const BorderSide(
                                    color: Color(0xFF23A455),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (_selectedFiles.isEmpty)
                                const Text(
                                  'لم يتم اختيار ملفات',
                                  style: TextStyle(color: Colors.grey),
                                )
                              else
                                ..._selectedFiles.map(
                                  (file) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.description),
                                    title: Text(
                                      file.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${file.extension?.toUpperCase() ?? 'FILE'} - ${(file.size / 1024 / 1024).toStringAsFixed(1)} MB',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        customButton(text: 'استمرار', onTap: _continue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
