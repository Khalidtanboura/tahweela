import 'package:flutter/material.dart';

Widget appbarCard({
  required IconData icon1,
  required IconData icon2,
  Color? color,
}) {
  return Container(
    height: 86,
    decoration: BoxDecoration(
      color: color ?? Color(0xFF1B9E4F),
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 33),
    child: Row(
      children: [
        Icon(icon1, color: Colors.white, size: 28),
        const SizedBox(width: 15),
        Icon(icon2, color: Colors.white, size: 28),
      ],
    ),
  );
}

Widget CaseCard({
  required String id,
  required String status,
  required Color statusColor,
  required Color statusTextColor,
  required String specialty,
  String patientName = "",
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.blue.shade50),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الحالة (Tag)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // رقم الحالة
            Text(
              id,
              style: const TextStyle(
                color: Color(0xFF1E5CC8),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // اسم المريض (إذا وجد)
        if (patientName.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              patientName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        // التخصص
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            specialty,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    ),
  );
}

Widget secoundAppbarCard({
  required IconData icon1,
  required String title,
  required BuildContext context,
  Color? color,
}) {
  return Container(
    width: double.infinity,
    height: 86,
    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
    decoration: BoxDecoration(
      color: Color(0xFF16A34A),
      // gradient: const LinearGradient(
      //   begin: Alignment.centerRight,
      //   end: Alignment.centerLeft,
      //   colors: [Color(0xFF16A34A), Color(0xFF0F7A38)],
      // ),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // زر الرجوع
        Positioned(
          left: 0,
          child: IconButton(
            icon: const Icon(Icons.reply, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        // العنوان
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget titleCard({required String title, Color? color1, Color? color2}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(top: 14, right: 23),
    height: 108,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [color1 ?? Color(0xFF0F7A38), color2 ?? Color(0xFF16A34A)],
      ),
      color: const Color(0xFF1B9E4F),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Text(
      title,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget appTitleCard({required String title, Color? color1, Color? color2}) {
  return Container(
    width: double.infinity,
    height: 87,
    decoration: BoxDecoration(
      color: const Color(0xFF1B9E4F),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Center(
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget CardQustion({required String title}) {
  return Container(
    margin: EdgeInsets.only(bottom: 7),

    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Row(
          children: [
            // زر نعم الأخضر
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Center(
                  child: Text(
                    "نعم — 1/1",
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // زر لا الأحمر
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFECACA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: const Center(
                  child: Text(
                    "لا — 1/0",
                    style: TextStyle(
                      color: Color(0xFF991B1B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget SecoundCard({
  required String value,
  required Color color,
  required String lableText,
}) {
  return Container(
    height: 100,
    padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          lableText,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    ),
  );
}
