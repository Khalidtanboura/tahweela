import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/models/referral_draft.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/providers.dart';

import '../../widgets/card.dart';

class SecondReferral extends ConsumerStatefulWidget {
  const SecondReferral({super.key, this.draft});

  final ReferralDraft? draft;

  @override
  ConsumerState<SecondReferral> createState() => _SecondReferralState();
}

class _SecondReferralState extends ConsumerState<SecondReferral> {
  final _notesController = TextEditingController();
  final List<bool?> _answers = List<bool?>.filled(_questions.length, null);
  bool _isSubmitting = false;

  static const _questions = [
    'هل العلاج متوفر داخل القطاع؟',
    'هل تحتاج الحالة تحويلا طبيا؟',
    'هل يوجد تقرير طبي يدعم الحالة؟',
    'هل تأخير العلاج يشكل خطرا على المريض؟',
    'هل الحالة عاجلة أو ذات أولوية؟',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _score => _answers.where((answer) => answer == true).length;

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final draft = widget.draft;
    if (draft == null) {
      _showSnackBar('بيانات الحالة غير مكتملة، يرجى الرجوع وإعادة المحاولة');
      return;
    }

    final missingAnswer = _answers.any((answer) => answer == null);
    if (missingAnswer) {
      _showSnackBar('يرجى الإجابة على جميع الأسئلة');
      return;
    }

    final doctor = await ref.read(userDataProvider.future);
    if (doctor == null) {
      _showSnackBar('تعذر تحديد بيانات الطبيب الحالي');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final attachments = await _uploadFiles(draft);
      final initialQuestions = List.generate(_questions.length, (index) {
        final answer = _answers[index] == true;
        return {
          'question': _questions[index],
          'answer': answer,
          'score': answer ? 1 : 0,
        };
      });

      await ref
          .read(referralsRepositoryProvider)
          .createReferral(
            doctorId: doctor.uid,
            doctorName: doctor.name,
            patientId: draft.patient.nationalId,
            patientName: draft.patient.fullName,
            diagnosis: draft.diseaseType,
            reason: _notesController.text.trim(),
            patientNationalId: draft.patient.nationalId,
            patientPhone: draft.phone,
            diseaseType: draft.diseaseType,
            attachments: attachments,
            initialQuestions: initialQuestions,
            initialScore: _score,
            initialNotes: _notesController.text.trim(),
          );

      if (!mounted) return;
      _showSnackBar('تم إنشاء حساب المريض وإرسال الحالة للمراجعة الطبية');
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseException catch (error) {
      debugPrint(
        'Referral submit FirebaseException: ${error.plugin}/${error.code} ${error.message}',
      );
      _showSnackBar('تعذر إرسال الحالة، يرجى المحاولة مرة أخرى');
    } catch (error) {
      _showSnackBar('تعذر إرسال الحالة: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<List<Map<String, dynamic>>> _uploadFiles(ReferralDraft draft) async {
    final storage = FirebaseStorage.instance;
    final referralFolder =
        'referrals/${draft.patient.nationalId}/${DateTime.now().millisecondsSinceEpoch}';
    final uploadedFiles = <Map<String, dynamic>>[];

    for (final file in draft.files) {
      final bytes = file.bytes;
      if (bytes == null) {
        throw StateError('تعذر قراءة الملف ${file.name}');
      }

      final safeName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final ref = storage.ref('$referralFolder/$safeName');
      final metadata = SettableMetadata(
        contentType: _contentTypeFor(file.extension),
      );
      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();
      uploadedFiles.add({
        'name': file.name,
        'url': url,
        'size': file.size,
        'extension': file.extension,
      });
    }

    return uploadedFiles;
  }

  String? _contentTypeFor(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return null;
    }
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
                  child: ListView(
                    children: [
                      const Text(
                        'أسئلة الحالة المدخلة',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'التقييم: $_score / ${_questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < _questions.length; i++)
                              _QuestionCard(
                                title: _questions[i],
                                value: _answers[i],
                                onChanged: (value) {
                                  setState(() => _answers[i] = value);
                                },
                              ),
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
                                    'ملاحظات',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _notesController,
                                    maxLines: 4,
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
                      const SizedBox(height: 18),
                      customButton(
                        text: _isSubmitting
                            ? 'جاري الإرسال...'
                            : 'إرسال الحالة للمراجعة الطبية',
                        onTap: _isSubmitting ? () {} : _submit,
                      ),
                    ],
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AnswerOption(
                  selected: value == true,
                  label: 'نعم - 1/1',
                  color: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFFD1FAE5),
                  groupValue: value,
                  optionValue: true,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnswerOption(
                  selected: value == false,
                  label: 'لا - 0/1',
                  color: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFFECACA),
                  groupValue: value,
                  optionValue: false,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.selected,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.groupValue,
    required this.optionValue,
    required this.onChanged,
  });

  final bool selected;
  final String label;
  final Color color;
  final Color backgroundColor;
  final bool? groupValue;
  final bool optionValue;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(optionValue),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected ? backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<bool>(
              value: optionValue,
              groupValue: groupValue,
              activeColor: color,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
