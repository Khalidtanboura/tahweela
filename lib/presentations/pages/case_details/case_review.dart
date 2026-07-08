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

  late final List<_DecisionQuestion> _questions = [
    _DecisionQuestion(
      key: 'A1',
      group: _ScoreGroup.core,
      criterion: 'خطر مباشر على الحياة',
      question: 'هل يوجد خطر وفاة خلال 24-48 ساعة بدون تدخل طبي؟',
      points: 10,
    ),
    _DecisionQuestion(
      key: 'A2',
      group: _ScoreGroup.core,
      criterion: 'فشل عضو حيوي',
      question: 'هل توجد علامات فشل في عضو حيوي (تنفس، قلب، دماغ)؟',
      points: 8,
    ),
    _DecisionQuestion(
      key: 'A3',
      group: _ScoreGroup.core,
      criterion: 'نزيف أو صدمة',
      question: 'هل يوجد نزيف شديد أو صدمة محتملة؟',
      points: 8,
    ),
    _DecisionQuestion(
      key: 'A4',
      group: _ScoreGroup.core,
      criterion: 'تدهور سريع',
      question: 'هل لوحظ تدهور سريع خلال آخر 24 ساعة؟',
      points: 7,
    ),
    _DecisionQuestion(
      key: 'A5',
      group: _ScoreGroup.core,
      criterion: 'حاجة لعناية مركزة',
      question: 'هل الحالة تتطلب عناية مركزة أو مراقبة مستمرة غير متاحة محليا؟',
      points: 7,
    ),
    _DecisionQuestion(
      key: 'B1',
      group: _ScoreGroup.delay,
      criterion: 'إعاقة دائمة',
      question: 'هل قد يؤدي التأخير إلى إعاقة دائمة أو فقدان وظيفة عضو؟',
      points: 6,
    ),
    _DecisionQuestion(
      key: 'B2',
      group: _ScoreGroup.delay,
      criterion: 'مضاعفات خطيرة',
      question: 'هل التأخير يزيد احتمال مضاعفات خطيرة؟',
      points: 5,
    ),
    _DecisionQuestion(
      key: 'B3',
      group: _ScoreGroup.delay,
      criterion: 'نافذة زمنية',
      question: 'هل الحالة تعتمد على نافذة زمنية حرجة (كل ساعة تحدث فرقا)؟',
      points: 6,
    ),
    _DecisionQuestion(
      key: 'B4',
      group: _ScoreGroup.delay,
      criterion: 'تدهور سابق',
      question: 'هل سبق تأجيل الحالة وتدهورت بعدها؟',
      points: 4,
    ),
    _DecisionQuestion(
      key: 'B5',
      group: _ScoreGroup.delay,
      criterion: 'أعراض غير مسيطر عليها',
      question: 'هل الألم أو الأعراض غير مسيطر عليها بالعلاج المتاح؟',
      points: 4,
    ),
    _DecisionQuestion(
      key: 'C1',
      group: _ScoreGroup.treatability,
      criterion: 'تدخل فعال',
      question: 'هل يوجد تدخل طبي معروف يحسن النتيجة بشكل واضح؟',
      points: 6,
    ),
    _DecisionQuestion(
      key: 'C2',
      group: _ScoreGroup.treatability,
      criterion: 'فرصة التحسن',
      question: 'هل فرص التحسن أو الشفاء مع التدخل متوسطة أو عالية؟',
      points: 6,
    ),
    _DecisionQuestion(
      key: 'C3',
      group: _ScoreGroup.treatability,
      criterion: 'وضوح التشخيص',
      question: 'هل التشخيص واضح ومدعوم بفحوصات وتقارير؟',
      points: 4,
    ),
    _DecisionQuestion(
      key: 'C4',
      group: _ScoreGroup.treatability,
      criterion: 'منع التدهور',
      question: 'هل التدخل المتوقع يمنع تدهورا كبيرا خلال أسبوع؟',
      points: 4,
    ),
    _DecisionQuestion(
      key: 'R1',
      group: _ScoreGroup.resource,
      criterion: 'العلاج متوفر عبر التحويل',
      question: 'هل العلاج غير متوفر محليا لكنه متوفر عبر التحويل؟',
      points: 5,
    ),
    _DecisionQuestion(
      key: 'R2',
      group: _ScoreGroup.resource,
      criterion: 'الخيار الواقعي الوحيد',
      question: 'هل التحويل هو الخيار الواقعي الوحيد للعلاج؟',
      points: 5,
    ),
    _DecisionQuestion(
      key: 'R3',
      group: _ScoreGroup.resource,
      criterion: 'بديل محلي أقل جودة',
      question: 'هل يوجد بديل محلي أقل جودة وقد يعرض المريض للخطر؟',
      points: 5,
    ),
    _DecisionQuestion(
      key: 'R4',
      group: _ScoreGroup.resource,
      criterion: 'العلاج غير متوفر',
      question: 'هل العلاج غير متوفر محليا ولا خارجيا حاليا؟',
      points: -5,
    ),
    _DecisionQuestion(
      key: 'R5',
      group: _ScoreGroup.resource,
      criterion: 'موارد نادرة وفرصة ضعيفة',
      question: 'هل العلاج يتطلب موارد نادرة جدا مع فرصة نجاح ضعيفة؟',
      points: -10,
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _coreScore => _sum(_ScoreGroup.core);
  int get _delayScore => _sum(_ScoreGroup.delay);
  int get _treatabilityScore => _sum(_ScoreGroup.treatability);
  int get _resourceAdjustment => _sum(_ScoreGroup.resource);

  int get _totalScore =>
      (_coreScore + _delayScore + _treatabilityScore + _resourceAdjustment)
          .clamp(0, 100)
          .toInt();

  String get _priorityLabel {
    if (_totalScore >= 90) return 'أولوية قصوى (Critical)';
    if (_totalScore >= 75) return 'أولوية عالية (High)';
    if (_totalScore >= 50) return 'أولوية متوسطة (Medium)';
    return 'أولوية منخفضة (Low)';
  }

  Color get _priorityColor {
    if (_totalScore >= 90) return const Color(0xFFDC2626);
    if (_totalScore >= 75) return const Color(0xFFF97316);
    if (_totalScore >= 50) return const Color(0xFF2563EB);
    return const Color(0xFF16A34A);
  }

  int _sum(_ScoreGroup group) {
    return _questions
        .where((question) => question.group == group && question.answer == true)
        .fold(0, (total, question) => total + question.points);
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
                        coreScore: _coreScore,
                        delayScore: _delayScore,
                        treatabilityScore: _treatabilityScore,
                        resourceAdjustment: _resourceAdjustment,
                      ),
                      const SizedBox(height: 14),
                      _QuestionSection(
                        title: '1. المعايير الطبية الأساسية (A)',
                        subtotal: _coreScore,
                        maxScore: MedicalScoreModel.maxCoreMedical,
                        questions: _questions
                            .where((item) => item.group == _ScoreGroup.core)
                            .toList(),
                        onChanged: _setAnswer,
                      ),
                      const SizedBox(height: 12),
                      _QuestionSection(
                        title: '2. أثر التأخير الزمني (B)',
                        subtotal: _delayScore,
                        maxScore: MedicalScoreModel.maxDelayImpact,
                        questions: _questions
                            .where((item) => item.group == _ScoreGroup.delay)
                            .toList(),
                        onChanged: _setAnswer,
                      ),
                      const SizedBox(height: 12),
                      _QuestionSection(
                        title: '3. قابلية الإنقاذ والفائدة المتوقعة (C)',
                        subtotal: _treatabilityScore,
                        maxScore: MedicalScoreModel.maxTreatability,
                        questions: _questions
                            .where(
                              (item) => item.group == _ScoreGroup.treatability,
                            )
                            .toList(),
                        onChanged: _setAnswer,
                      ),
                      const SizedBox(height: 12),
                      _QuestionSection(
                        title: '4. عامل تعديل الموارد في ظل الحصار (R)',
                        subtitle:
                            'تعامل هذه الحالات كنعم/لا، وتدخل ضمن النتيجة النهائية من 100.',
                        subtotal: _resourceAdjustment,
                        maxScore: MedicalScoreModel.maxResourceAdjustment,
                        questions: _questions
                            .where((item) => item.group == _ScoreGroup.resource)
                            .toList(),
                        onChanged: _setAnswer,
                      ),
                      const SizedBox(height: 12),
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

  void _setAnswer(_DecisionQuestion question, bool value) {
    setState(() => question.answer = value);
  }

  Future<void> _submitReview() async {
    final reviewer = ref.read(userDataProvider).value;
    if (reviewer == null) {
      _showSnackBar('تعذر تحديد بيانات الطبيب الحالي');
      return;
    }

    final score = MedicalScoreModel(
      coreMedical: _coreScore,
      delayImpact: _delayScore,
      treatability: _treatabilityScore,
      resourceAdjustment: _resourceAdjustment,
    );
    final answers = _questions
        .map(
          (question) => {
            'key': question.key,
            'group': question.group.name,
            'criterion': question.criterion,
            'question': question.question,
            'answer': question.answer,
            'score': question.answer == true ? question.points : 0,
            'pointValue': question.points,
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
    required this.coreScore,
    required this.delayScore,
    required this.treatabilityScore,
    required this.resourceAdjustment,
  });

  final ReferralModel referral;
  final int totalScore;
  final String priorityLabel;
  final Color priorityColor;
  final int coreScore;
  final int delayScore;
  final int treatabilityScore;
  final int resourceAdjustment;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScoreChip(label: 'A', value: '$coreScore/40'),
              _ScoreChip(label: 'B', value: '$delayScore/25'),
              _ScoreChip(label: 'C', value: '$treatabilityScore/20'),
              _ScoreChip(
                label: 'R',
                value: resourceAdjustment > 0
                    ? '+$resourceAdjustment'
                    : '$resourceAdjustment',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'النتيجة النهائية: $totalScore / 100',
            style: TextStyle(
              color: priorityColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تصنيف الأولوية: $priorityLabel',
            style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  const _QuestionSection({
    required this.title,
    this.subtitle,
    required this.subtotal,
    required this.maxScore,
    required this.questions,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final int subtotal;
  final int maxScore;
  final List<_DecisionQuestion> questions;
  final void Function(_DecisionQuestion question, bool value) onChanged;

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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _ScoreChip(label: 'المجموع', value: '$subtotal/$maxScore'),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          for (final question in questions) ...[
            _DecisionQuestionTile(
              question: question,
              onChanged: (value) => onChanged(question, value),
            ),
            if (question != questions.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _DecisionQuestionTile extends StatelessWidget {
  const _DecisionQuestionTile({
    required this.question,
    required this.onChanged,
  });

  final _DecisionQuestion question;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _CodeBadge(text: question.key),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question.criterion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          question.question,
          style: const TextStyle(color: Color(0xFF475569), height: 1.4),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                label: 'نعم',
                selected: question.answer == true,
                color: const Color(0xFF16A34A),
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _AnswerButton(
                label: 'لا',
                selected: question.answer == false,
                color: const Color(0xFFDC2626),
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.white : color,
        backgroundColor: selected ? color : Colors.white,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: const Color(0xFFEFF6FF),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: Color(0xFF1D4ED8),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  const _CodeBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.bold,
        ),
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

enum _ScoreGroup { core, delay, treatability, resource }

class _DecisionQuestion {
  _DecisionQuestion({
    required this.key,
    required this.group,
    required this.criterion,
    required this.question,
    required this.points,
  });

  final String key;
  final _ScoreGroup group;
  final String criterion;
  final String question;
  final int points;
  bool? answer;
}
