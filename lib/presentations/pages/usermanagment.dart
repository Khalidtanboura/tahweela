import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/add_user_dialog.dart';
import 'package:tahweela/presentations/widgets/card.dart';

class UserManagment extends StatefulWidget {
  const UserManagment({super.key});

  @override
  State<UserManagment> createState() => _UserManagmentState();
}

class _UserManagmentState extends State<UserManagment> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();
  }

  void _reloadUsers() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  Future<void> _deleteUser({
    required String userId,
    required String name,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل تريد حذف المستخدم "$name" من القائمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (!mounted) return;
      _reloadUsers();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف المستخدم بنجاح')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حذف المستخدم: $error')));
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'طبيب مراجع';
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
        backgroundColor: const Color(0xffF8FAFC),
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
                  child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    future: _usersFuture,
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
                        padding: const EdgeInsets.only(bottom: 92),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final doc = users[index];
                          final user = doc.data();
                          final roleKey =
                              user['role']?.toString().trim() ?? 'admin';
                          final name =
                              user['name']?.toString().trim().isNotEmpty == true
                              ? user['name'].toString()
                              : 'بدون اسم';
                          final phone =
                              user['phone']?.toString().trim().isNotEmpty ==
                                  true
                              ? user['phone'].toString()
                              : user['nationalID']?.toString() ??
                                    user['nationalId']?.toString() ??
                                    '';
                          final specialty =
                              user['specialty']?.toString().trim() ?? '';
                          final role =
                              specialty.isNotEmpty && roleKey == 'doctor'
                              ? '${_getRoleLabel(roleKey)} - $specialty'
                              : _getRoleLabel(roleKey);

                          return _UserCard(
                            name: name,
                            subtitle: role,
                            phone: phone,
                            roleKey: roleKey,
                            canDelete: roleKey != 'admin',
                            onDelete: () =>
                                _deleteUser(userId: doc.id, name: name),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (_) => const AddUserDialog(),
            );
            if (context.mounted) _reloadUsers();
          },
          backgroundColor: const Color(0xFF16A34A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.person_add_alt_1,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.name,
    required this.subtitle,
    required this.phone,
    required this.roleKey,
    required this.canDelete,
    required this.onDelete,
  });

  final String name;
  final String subtitle;
  final String phone;
  final String roleKey;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final style = _roleStyle(roleKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
      child: Row(
        children: [
          if (canDelete)
            IconButton(
              tooltip: 'حذف المستخدم',
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
                size: 32,
              ),
            )
          else
            const SizedBox(width: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: style.badgeColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: style.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  phone.isEmpty ? 'لا يوجد رقم' : phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8A8F98),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: style.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.iconColor, size: 34),
          ),
        ],
      ),
    );
  }

  _RoleStyle _roleStyle(String role) {
    switch (role) {
      case 'doctor':
        return const _RoleStyle(
          icon: Icons.medical_services_rounded,
          iconColor: Color(0xFF16A34A),
          iconBackground: Color(0xFFDDF7E8),
          badgeColor: Color(0xFFE8FAF0),
          textColor: Color(0xFF159447),
        );
      case 'patient':
        return const _RoleStyle(
          icon: Icons.person_rounded,
          iconColor: Color(0xFFF59E0B),
          iconBackground: Color(0xFFFFF1D8),
          badgeColor: Color(0xFFFFF7E8),
          textColor: Color(0xFFD97706),
        );
      case 'admin':
        return const _RoleStyle(
          icon: Icons.admin_panel_settings_rounded,
          iconColor: Color(0xFFDC2626),
          iconBackground: Color(0xFFFDE0E3),
          badgeColor: Color(0xFFFDECEC),
          textColor: Color(0xFFB91C1C),
        );
      default:
        return const _RoleStyle(
          icon: Icons.edit_document,
          iconColor: Color(0xFF2563EB),
          iconBackground: Color(0xFFE1EAFF),
          badgeColor: Color(0xFFEFF5FF),
          textColor: Color(0xFF1D4ED8),
        );
    }
  }
}

class _RoleStyle {
  const _RoleStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.badgeColor,
    required this.textColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color badgeColor;
  final Color textColor;
}
