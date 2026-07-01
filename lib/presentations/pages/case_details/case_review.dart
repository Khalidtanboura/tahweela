import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/models/medical_score_model.dart';
import 'package:tahweela/data/models/referral_model.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/providers.dart';

import '../../widgets/card.dart';

class CaseReview extends ConsumerStatefulWidget {
  const CaseReview({super.key, required this.referral});

  final ReferralModel referral;

  @override
  ConsumerState<CaseReview> createState() => _CaseReviewState();
}

class _CaseReviewState extends ConsumerState<CaseReview> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  late final List<_ReviewQuestion> _questions = [
    _ReviewQuestion(
      key: 'coreMedical',
      title: 'خطورة الحالة الطبية الحالية',
      description:
          'قيّم شدة الحالة، احتمال المضاعفات، ومدى تأثيرها على سلامة المريض.',
      maxScore: MedicalScoreModel.maxCoreMedical,
      value: widget.referral.medicalScore.coreMedical,
    ),
    _ReviewQuestion(
      key: 'delayImpact',
      title: 'تأثير تأخير العلاج',
      description: 'قيّم مقدار الضرر المتوقع إذا تأخر التدخل أو التحويل الطبي.',
      maxScore: MedicalScoreModel.maxDelayImpact,
      value: widget.referral.medicalScore.delayImpact,
    ),
    _ReviewQuestion(
      key: 'treatability',
      title: 'قابلية التحسن بالعلاج',
      description: 'قيّم فرصة تحسن الحالة عند توفر العلاج أو التدخل المناسب.',
      maxScore: MedicalScoreModel.maxTreatability,
      value: widget.referral.medicalScore.treatability,
    ),
    _ReviewQuestion(
      key: 'resourceAdjustment',
      title: 'الحاجة للموارد والتجهيزات',
      description:
          'قيّم حاجة الحالة لتجهيزات، أسرّة، أدوية، أو تدخل تخصصي سريع.',
      maxScore: MedicalScoreModel.maxResourceAdjustment,
      value: widget.referral.medicalScore.resourceAdjustment,
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _totalScore =>
      _questions.fold(0, (total, question) => total + question.value);

  String get _priorityLabel {
    if (_totalScore >= 90) return 'حرجة';
    if (_totalScore >= 75) return 'عالية';
    if (_totalScore >= 50) return 'متوسطة';
    return 'منخفضة';
  }

  Color get _priorityColor {
    if (_totalScore >= 90) return const Color(0xFFDC2626);
    if (_totalScore >= 75) return const Color(0xFFF97316);
    if (_totalScore >= 50) return const Color(0xFF2563EB);
    return const Color(0xFF16A34A);
  }

  @override
  Widget build(BuildContext context) {
    final referral = widget.referral;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                secoundAppbarCard(
                  icon1: Icons.reply,
                  title: 'تقييم الحالة',
                  context: context,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _CaseSummary(
                        referral: referral,
                        totalScore: _totalScore,
                        priorityLabel: _priorityLabel,
                        priorityColor: _priorityColor,
                      ),
                      const SizedBox(height: 14),
                      for (final question in _questions) ...[
                        _QuestionScoreCard(
                          question: question,
                          onChanged: (value) {
                            setState(() => question.value = value);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      _NotesField(controller: _notesController),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitReview,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isSubmitting ? 'جار حفظ التقييم...' : 'حفظ التقييم',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Future<void> _submitReview() async {
    final reviewer = ref.read(userDataProvider).value;
    if (reviewer == null) {
      _showSnackBar('تعذر تحديد بيانات الطبيب الحالي');
      return;
    }

    final score = MedicalScoreModel(
      coreMedical: _questions
          .firstWhere((item) => item.key == 'coreMedical')
          .value,
      delayImpact: _questions
          .firstWhere((item) => item.key == 'delayImpact')
          .value,
      treatability: _questions
          .firstWhere((item) => item.key == 'treatability')
          .value,
      resourceAdjustment: _questions
          .firstWhere((item) => item.key == 'resourceAdjustment')
          .value,
    );
    final answers = _questions
        .map(
          (question) => {
            'key': question.key,
            'question': question.title,
            'description': question.description,
            'score': question.value,
            'maxScore': question.maxScore,
          },
        )
        .toList();

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(referralsRepositoryProvider)
          .submitMedicalReview(
            referralId: widget.referral.id,
            reviewerId: reviewer.uid,
            reviewerName: reviewer.name,
            score: score,
            answers: answers,
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;
      _showSnackBar('تم حفظ تقييم الحالة بنجاح');
      Navigator.pop(context);
    } catch (error) {
      _showSnackBar('تعذر حفظ تقييم الحالة: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CaseSummary extends StatelessWidget {
  const _CaseSummary({
    required this.referral,
    required this.totalScore,
    required this.priorityLabel,
    required this.priorityColor,
  });

  final ReferralModel referral;
  final int totalScore;
  final String priorityLabel;
  final Color priorityColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            referral.patientName.isEmpty
                ? 'مريض غير محدد'
                : referral.patientName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'التخصص: ${referral.assignedSpecialty.isEmpty ? referral.diseaseType : referral.assignedSpecialty}',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Text(
            'سبب التحويل: ${referral.reason.isEmpty ? 'لا يوجد سبب مدخل' : referral.reason}',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: totalScore / 100,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation(priorityColor),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$totalScore / 100',
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الأولوية: $priorityLabel',
            style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuestionScoreCard extends StatelessWidget {
  const _QuestionScoreCard({required this.question, required this.onChanged});

  final _ReviewQuestion question;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Text(
                '${question.value}/${question.maxScore}',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.description,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
          ),
          Slider(
            value: question.value.toDouble(),
            min: 0,
            max: question.maxScore.toDouble(),
            divisions: question.maxScore,
            label: question.value.toString(),
            activeColor: const Color(0xFF2563EB),
            onChanged: (value) => onChanged(value.round()),
          ),
        ],
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: 'ملاحظات الطبيب المقيم',
        hintText: 'اكتب أي ملاحظات طبية داعمة للتقييم',
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _ReviewQuestion {
  _ReviewQuestion({
    required this.key,
    required this.title,
    required this.description,
    required this.maxScore,
    required this.value,
  });

  final String key;
  final String title;
  final String description;
  final int maxScore;
  int value;
}
