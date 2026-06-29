import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/add_user_dialog.dart';
import 'package:tahweela/presentations/widgets/card.dart';

class UserManagment extends StatelessWidget {
  const UserManagment({super.key});

  String _getRoleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'طبيب';
      case 'patient':
        return 'مريض';
      case 'admin':
      default:
        return 'مدير النظام';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                secoundAppbarCard(
                  title: 'إدارة المستخدمين',
                  icon1: Icons.reply,
                  context: context,
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF16A34A),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا يوجد مستخدمون',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final users = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index].data();
                          final name = user['name']?.toString() ?? 'بدون اسم';
                          final role = _getRoleLabel(
                            user['role']?.toString() ?? 'admin',
                          );
                          final specialty = user['specialty']?.toString() ?? '';
                          final nationalId =
                              user['nationalID']?.toString() ??
                              user['nationalId']?.toString() ??
                              '';

                          return _UserCard(
                            name: name,
                            subtitle: specialty.isNotEmpty
                                ? '$role - $specialty'
                                : role,
                            nationalId: nationalId,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (_) => const AddUserDialog());
          },
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.name,
    required this.subtitle,
    required this.nationalId,
  });

  final String name;
  final String subtitle;
  final String nationalId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E5EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (nationalId.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'رقم الهوية: $nationalId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
