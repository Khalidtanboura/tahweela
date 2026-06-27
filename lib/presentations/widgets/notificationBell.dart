import 'package:flutter/material.dart';
import 'package:tahweela/presentations/pages/notification.dart';

Widget buildNotificationBell(BuildContext context, int unreadCount) {
  return Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      IconButton(
        icon: const Icon(Icons.notifications_none_rounded, size: 28),
        onPressed: () {
          // الانتقال الموحد لشاشة الإشعارات الذكية التي برمجناها سابقاً
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationPage()),
          );
        },
      ),
      if (unreadCount > 0)
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              '$unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );
}
