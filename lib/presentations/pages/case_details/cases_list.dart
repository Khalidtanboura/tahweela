import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/models/referral_model.dart';
import 'package:tahweela/presentations/pages/case_details/case_review.dart';
import 'package:tahweela/presentations/widgets/card.dart';
import 'package:tahweela/providers/providers.dart';

class CasesList extends ConsumerWidget {
  const CasesList({super.key, this.mode = CasesListMode.admin});

  final CasesListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralsAsync = switch (mode) {
      CasesListMode.medicalReview => ref.watch(medicalReviewReferralsProvider),
      CasesListMode.patient => ref.watch(patientReferralsProvider),
      CasesListMode.admin => ref.watch(adminReferralsProvider),
    };
    final title = switch (mode) {
      CasesListMode.medicalReview => 'مراجعة الحالات',
      CasesListMode.patient => 'طلباتي',
      CasesListMode.admin => 'جميع الحالات',
    };
    final emptyMessage = switch (mode) {
      CasesListMode.medicalReview =>
        'لا توجد حالات ضمن اختصاصك بانتظار التقييم حاليا',
      CasesListMode.patient => 'لا توجد طلبات حتى الآن',
      CasesListMode.admin => 'لا توجد حالات حتى الآن',
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                secoundAppbarCard(
                  title: title,
                  icon1: Icons.reply,
                  context: context,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: referralsAsync.when(
                    data: (referrals) {
                      if (referrals.isEmpty) {
                        return Center(
                          child: Text(
                            emptyMessage,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: referrals.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _ReferralCard(
                            referral: referrals[index],
                            mode: mode,
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Text(
                        'Failed to load referrals: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
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

class _ReferralCard extends ConsumerWidget {
  const _ReferralCard({required this.referral, required this.mode});

  final ReferralModel referral;
  final CasesListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priority = _priorityLabel(referral.priorityLevel);
    final status = _statusLabel(referral.status);
    final canApprove =
        mode == CasesListMode.admin && referral.status == 'pending';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: mode == CasesListMode.medicalReview
          ? () => _openMedicalReview(context)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    referral.patientName.isEmpty
                        ? 'Unnamed patient'
                        : referral.patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                _Badge(
                  label: status,
                  backgroundColor: canApprove
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFEFF6FF),
                  textColor: canApprove
                      ? const Color(0xFFC2410C)
                      : const Color(0xFF1D4ED8),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'د. ${referral.doctorName.isEmpty ? 'Unnamed doctor' : referral.doctorName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'التخصص: ${referral.diagnosis.isEmpty ? 'No diagnosis' : referral.diagnosis}',
              style: const TextStyle(color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            Text(
              'سبب التحويل: ${referral.reason.isEmpty ? 'لا يوجد سبب' : referral.reason}',
              style: const TextStyle(color: Color(0xFF334155)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Badge(
                  label: 'Priority: $priority',
                  backgroundColor: _priorityColor(
                    referral.priorityLevel,
                  ).withValues(alpha: 0.12),
                  textColor: _priorityColor(referral.priorityLevel),
                ),
                const SizedBox(width: 8),
                _Badge(
                  label: 'Score: ${referral.totalScore}/100',
                  backgroundColor: const Color(0xFFF1F5F9),
                  textColor: const Color(0xFF334155),
                ),
              ],
            ),
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
                  'Approve referral',
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
        title: const Text('Approve referral'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'Optional admin note',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral approved successfully')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve referral: $error')),
        );
      }
    }
  }
}

enum CasesListMode { admin, patient, medicalReview }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

String _priorityLabel(String priority) {
  switch (priority) {
    case 'critical':
      return 'Critical';
    case 'high':
      return 'High';
    case 'medium':
      return 'Medium';
    case 'low':
    default:
      return 'Low';
  }
}

Color _priorityColor(String priority) {
  switch (priority) {
    case 'critical':
      return const Color(0xFFDC2626);
    case 'high':
      return const Color(0xFFF97316);
    case 'medium':
      return const Color(0xFF2563EB);
    case 'low':
    default:
      return const Color(0xFF16A34A);
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'approved':
    case 'accepted':
      return 'Approved';
    case 'returned':
      return 'Returned';
    case 'pending':
    default:
      return 'Pending review';
  }
}
