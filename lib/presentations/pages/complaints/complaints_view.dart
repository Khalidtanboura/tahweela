import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/card.dart';

class ComplaintsView extends StatefulWidget {
  const ComplaintsView({super.key});

  @override
  State<ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<ComplaintsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            secoundAppbarCard(
              icon1: Icons.reply,
              title: 'الشكاوي',
              context: context,
            ),

            const SizedBox(height: 20),

            // Tab Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton("شكاوي الأطباء", isSelected: false),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTabButton("شكاوي المرضى", isSelected: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Complaints List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  ComplaintCard(
                    id: "TH-2026-00008",
                    name: "خالد المريض",
                    department: "جراحة عامة",
                    date: "15/05/2050",
                    status: "مقبول",
                    statusColor: Colors.green,
                  ),
                  ComplaintCard(
                    id: "TH-2026-00002",
                    name: "محمد المريض",
                    department: "جراحة عظام",
                    date: "15/05/2050",
                    status: "قيد المراجعة",
                    statusColor: Color(0xFFFFEAA7),
                    statusTextColor: Colors.orange,
                  ),
                  ComplaintCard(
                    id: "TH-2026-00003",
                    name: "سعيد المريض",
                    department: "أورام",
                    date: "15/05/2050",
                    status: "مرفوضة",
                    statusColor: Colors.red,
                  ),
                  ComplaintCard(
                    id: "DR-2026-00011",
                    name: "الدكتور سعيد",
                    department: "أورام",
                    date: "15/05/2050",
                    status: "قيد المراجعة",
                    statusColor: Color(0xFFFFEAA7),
                    statusTextColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[200] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String id, name, department, date, status;
  final Color statusColor;
  final Color statusTextColor;

  const ComplaintCard({
    super.key,
    required this.id,
    required this.name,
    required this.department,
    required this.date,
    required this.status,
    required this.statusColor,
    this.statusTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
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
          const Spacer(),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                id,
                style: const TextStyle(
                  color: Color(0xFF2D7FF9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                department,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "التاريخ : $date",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
