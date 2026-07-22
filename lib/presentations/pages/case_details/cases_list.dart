import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/models/referral_model.dart';
import 'package:tahweela/presentations/pages/case_details/case_review.dart';
import 'package:tahweela/presentations/widgets/card.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/providers.dart';

class CasesList extends ConsumerStatefulWidget {
  const CasesList({super.key, this.mode = CasesListMode.admin});

  final CasesListMode mode;

  @override
  ConsumerState<CasesList> createState() => _CasesListState();
}

class _CasesListState extends ConsumerState<CasesList> {
  late final Future<List<ReferralModel>> _referralsFuture;
  _CaseFilter _selectedFilter = _CaseFilter.all;

  @override
  void initState() {
    super.initState();
    _referralsFuture = _loadReferrals();
  }

  Future<List<ReferralModel>> _loadReferrals() async {
    final repo = ref.read(referralsRepositoryProvider);

    switch (widget.mode) {
      case CasesListMode.medicalReview:
        final user = await ref.read(userDataProvider.future);
        return repo.fetchMedicalReviewReferrals(
          specialty: user?.specialty,
          reviewerId: user?.uid,
        );
      case CasesListMode.patient:
        final user = await ref.read(userDataProvider.future);
        if (user == null) return const <ReferralModel>[];
        return repo.fetchReferralModels(role: 'patient', uid: user.uid);
      case CasesListMode.admin:
        return repo.fetchReferralModels(role: 'admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      CasesListMode.medicalReview => 'مراجعة الحالات',
      CasesListMode.patient => 'طلباتي',
      CasesListMode.admin => 'الحالات',
    };
    final emptyMessage = switch (widget.mode) {
      CasesListMode.medicalReview =>
        'لا توجد حالات ضمن اختصاصك بانتظار التقييم حاليا',
      CasesListMode.patient => 'لا توجد طلبات حتى الآن',
      CasesListMode.admin => 'لا توجد حالات حتى الآن',
    };
    final showFilters = widget.mode == CasesListMode.admin;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: secoundAppbarCard(
                  title: title,
                  icon1: Icons.reply,
                  context: context,
                ),
              ),
              if (showFilters)
                _FilterBar(
                  selectedFilter: _selectedFilter,
                  onChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              Expanded(
                child: FutureBuilder<List<ReferralModel>>(
                  future: _referralsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF16A34A),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'تعذر تحميل الحالات: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final referrals = snapshot.data ?? const <ReferralModel>[];
                    final filteredReferrals = showFilters
                        ? referrals
                              .where(
                                (referral) =>
                                    _matchesFilter(referral, _selectedFilter),
                              )
                              .toList()
                        : referrals;

                    if (filteredReferrals.isEmpty) {
                      return Center(
                        child: Text(
                          showFilters
                              ? 'لا توجد حالات ضمن هذا التصنيف'
                              : emptyMessage,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                      itemCount: filteredReferrals.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _ReferralCard(
                          referral: filteredReferrals[index],
                          displayIndex:
                              referrals.indexOf(filteredReferrals[index]) + 1,
                          mode: widget.mode,
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
    );
  }

  bool _matchesFilter(ReferralModel referral, _CaseFilter filter) {
    final status = referral.status.trim().toLowerCase();

    switch (filter) {
      case _CaseFilter.all:
        return true;
      case _CaseFilter.draft:
        return status == 'draft' || status == 'مسودة';
      case _CaseFilter.pending:
        return status == 'pending' ||
            status == 'approved' ||
            status == 'under_medical_review' ||
            status == 'reviewed';
      case _CaseFilter.accepted:
        return status == 'accepted';
      case _CaseFilter.rejected:
        return status == 'rejected';
    }
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selectedFilter, required this.onChanged});

  final _CaseFilter selectedFilter;
  final ValueChanged<_CaseFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            for (final filter in _CaseFilter.values) ...[
              _FilterChip(
                label: filter.label,
                selected: selectedFilter == filter,
                onTap: () => onChanged(filter),
              ),
              if (filter != _CaseFilter.values.last) const SizedBox(width: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAFBF1) : const Color(0xFFF3FCF7),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF159447)
                      : const Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralCard extends ConsumerWidget {
  const _ReferralCard({
    required this.referral,
    required this.displayIndex,
    required this.mode,
  });

  final ReferralModel referral;
  final int displayIndex;
  final CasesListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusStyle = _statusStyle(referral.status);
    final priorityStyle = _priorityStyle(referral.priorityLevel);
    final patientName = referral.patientName.isEmpty
        ? 'مريض غير معروف'
        : referral.patientName;
    final specialty = referral.assignedSpecialty.isNotEmpty
        ? referral.assignedSpecialty
        : referral.diseaseType.isNotEmpty
        ? referral.diseaseType
        : referral.diagnosis;
    final score = referral.totalScore.clamp(0, 100).toInt();
    final caseNumber = _caseNumber(referral, displayIndex);
    final canApprove =
        mode == CasesListMode.admin && referral.status == 'pending';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: mode == CasesListMode.medicalReview
          ? () => _openMedicalReview(context)
          : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(
                      label: statusStyle.label,
                      backgroundColor: statusStyle.backgroundColor,
                      textColor: statusStyle.textColor,
                    ),
                    const SizedBox(height: 76),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PriorityPill(style: priorityStyle),
                        const SizedBox(width: 12),
                        _ScoreRing(
                          score: score,
                          color: priorityStyle.textColor,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        caseNumber,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF1E5CC8),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        patientName,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              specialty.isEmpty ? 'غير محدد' : specialty,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF7C828A),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.medical_services_outlined,
                            color: Color(0xFF8A8F98),
                            size: 22,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (referral.medicalReviewCount > 0 ||
                referral.hasFinalMedicalDecision) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(
                    label: 'التقييمات: ${referral.medicalReviewCount}/3',
                    backgroundColor: const Color(0xFFF8FAFC),
                    textColor: const Color(0xFF475569),
                  ),
                  if (referral.averageMedicalScore > 0)
                    _Badge(
                      label: 'المتوسط: ${referral.averageMedicalScore}/100',
                      backgroundColor: const Color(0xFFF8FAFC),
                      textColor: const Color(0xFF475569),
                    ),
                ],
              ),
            ],
            if (mode == CasesListMode.medicalReview) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _openMedicalReview(context),
                icon: const Icon(
                  Icons.rate_review_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'بدء التقييم الطبي',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            if (canApprove) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _approveReferral(context, ref),
                icon: const Icon(Icons.verified_outlined, color: Colors.white),
                label: const Text(
                  'اعتماد الحالة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _caseNumber(ReferralModel referral, int index) {
    if (referral.id.trim().isEmpty) {
      return 'TH-${DateTime.now().year}-${index.toString().padLeft(5, '0')}';
    }

    final cleaned = referral.id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final suffix = cleaned.length <= 5
        ? cleaned.padLeft(5, '0')
        : cleaned.substring(cleaned.length - 5);
    return 'TH-${DateTime.now().year}-$suffix';
  }

  void _openMedicalReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CaseReview(referral: referral)),
    );
  }

  Future<void> _approveReferral(BuildContext context, WidgetRef ref) async {
    final noteController = TextEditingController();
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اعتماد الحالة'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'ملاحظة إدارية اختيارية',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('اعتماد'),
          ),
        ],
      ),
    );

    if (approved != true || !context.mounted) return;

    try {
      await ref
          .read(referralsRepositoryProvider)
          .approveReferral(
            referralId: referral.id,
            doctorId: referral.doctorId,
            patientId: referral.patientId,
            adminReply: noteController.text.trim(),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم اعتماد الحالة بنجاح')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر اعتماد الحالة: $error')));
      }
    }
  }
}

enum CasesListMode { admin, patient, medicalReview }

enum _CaseFilter {
  all('الكل'),
  draft('مسودة'),
  pending('قيد المراجعة'),
  accepted('مقبولة'),
  rejected('مرفوضة');

  const _CaseFilter(this.label);

  final String label;
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.style});

  final _PriorityStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.borderColor),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

_StatusStyle _statusStyle(String status) {
  switch (status.trim().toLowerCase()) {
    case 'accepted':
      return const _StatusStyle(
        label: 'مقبول',
        backgroundColor: Color(0xFFE2F7EA),
        textColor: Color(0xFF16A34A),
      );
    case 'rejected':
      return const _StatusStyle(
        label: 'مرفوض',
        backgroundColor: Color(0xFFFDE8E8),
        textColor: Color(0xFFDC2626),
      );
    case 'draft':
      return const _StatusStyle(
        label: 'مسودة',
        backgroundColor: Color(0xFFF3F4F6),
        textColor: Color(0xFF9CA3AF),
      );
    case 'pending':
      return const _StatusStyle(
        label: 'قيد المراجعة',
        backgroundColor: Color(0xFFFFF4DE),
        textColor: Color(0xFFD99624),
      );
    case 'approved':
    case 'under_medical_review':
    default:
      return const _StatusStyle(
        label: 'قيد المراجعة',
        backgroundColor: Color(0xFFFFF4DE),
        textColor: Color(0xFFD99624),
      );
  }
}

_PriorityStyle _priorityStyle(String priority) {
  switch (priority) {
    case 'critical':
      return const _PriorityStyle(
        label: 'حرج',
        backgroundColor: Color(0xFFFDE8E8),
        borderColor: Color(0xFFFCA5A5),
        textColor: Color(0xFFDC2626),
      );
    case 'high':
      return const _PriorityStyle(
        label: 'عالي',
        backgroundColor: Color(0xFFFFF4DE),
        borderColor: Color(0xFFF6D58B),
        textColor: Color(0xFFF59E0B),
      );
    case 'medium':
      return const _PriorityStyle(
        label: 'متوسط',
        backgroundColor: Color(0xFFEFF6FF),
        borderColor: Color(0xFFBFDBFE),
        textColor: Color(0xFF2563EB),
      );
    case 'low':
    default:
      return const _PriorityStyle(
        label: 'منخفض',
        backgroundColor: Color(0xFFF3F4F6),
        borderColor: Color(0xFFD1D5DB),
        textColor: Color(0xFF6B7280),
      );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
}

class _PriorityStyle {
  const _PriorityStyle({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}
