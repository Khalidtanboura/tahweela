import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tahweela/data/repositories/notifications_repository.dart';
import 'package:tahweela/presentations/widgets/card.dart';
import 'package:tahweela/presentations/widgets/text.dart';

class ComplaintsState extends StatefulWidget {
  final String complaintId;
  final Map<String, dynamic> complaintData;

  const ComplaintsState({
    super.key,
    required this.complaintId,
    required this.complaintData,
  });

  @override
  State<ComplaintsState> createState() => _ComplaintsStateState();
}

class _ComplaintsStateState extends State<ComplaintsState> {
  final _replyController = TextEditingController();
  bool _isLoading = false;

  String _getStatusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'مقبولة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return 'قيد المراجعة';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xFFFFEAA7);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFD35400);
      default:
        return Colors.white;
    }
  }

  Future<void> _updateComplaint(String newStatus) async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة نص الرد أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaintId)
          .update({
            'status': newStatus,
            'replyText': _replyController.text.trim(),
          });
      final userId = widget.complaintData['userId']?.toString() ?? '';
      final userRole = widget.complaintData['userRole']?.toString() ?? '';
      final replyText = _replyController.text.trim();
      final statusText = newStatus == 'accepted' ? 'قبول' : 'رفض';
      final notificationsRepo = NotificationsRepository();

      if (userId.isNotEmpty && userRole == 'doctor') {
        await notificationsRepo.sendNotificationToDoctor(
          doctorUid: userId,
          title: 'تم تحديث حالة شكواك',
          body: 'تم $statusText الشكوى. رد الإدارة: $replyText',
          type: 'complaint_update',
          relatedId: widget.complaintId,
          routeName: 'complaintsDoctorCase',
        );
      } else if (userId.isNotEmpty) {
        await notificationsRepo.sendNotificationToPatient(
          patientUid: userId,
          title: 'تم تحديث حالة شكواك',
          body: 'تم $statusText الشكوى. رد الإدارة: $replyText',
          type: 'complaint_update',
          relatedId: widget.complaintId,
          routeName: 'complaintsPatientCase',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'accepted' ? 'تم قبول الشكوى ✅' : 'تم رفض الشكوى ❌',
            ),
            backgroundColor: newStatus == 'accepted'
                ? Colors.green
                : Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.complaintData;
    final status = data['status'] ?? 'pending';
    final isPending = status == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'حالة الشكوى',
                context: context,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // بطاقة معلومات الشكوى
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    _getStatusLabel(status),
                                    style: TextStyle(
                                      color: _getStatusTextColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  data['userName'] ?? 'مجهول',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                data['userRole'] == 'doctor' ? 'طبيب' : 'مريض',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // نص الشكوى
                      mySectionTitle("نص الشكوى"),
                      myContentBox(data['text'] ?? ''),

                      const SizedBox(height: 20),

                      // الرد على الشكوى
                      mySectionTitle("الرد على الشكوى"),

                      // لو الشكوى مو pending بيظهر الرد القديم
                      if (!isPending)
                        myContentBox(
                          data['replyText'] ?? 'لا يوجد رد',
                          textColor: Colors.grey,
                        )
                      // لو pending بيظهر حقل الكتابة
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: TextField(
                            controller: _replyController,
                            maxLines: 4,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(15),
                              hintText: 'اكتب ردك هنا...',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),

                      const SizedBox(height: 30),

                      // أزرار القبول والرفض (تظهر فقط لو pending)
                      if (isPending)
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF16A34A),
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: myOutlineButton(
                                      "رفض شكوى",
                                      Colors.red,
                                      onTap: () => _updateComplaint('rejected'),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: myOutlineButton(
                                      "قبول شكوى",
                                      Colors.green,
                                      onTap: () => _updateComplaint('accepted'),
                                    ),
                                  ),
                                ],
                              ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
