import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';
import 'package:tahweela/presentations/widgets/dropdown_menu.dart';

import '../../../core/theme.dart';
import '../../widgets/card.dart';

class NewReferral extends StatefulWidget {
  const NewReferral({super.key});

  @override
  State<NewReferral> createState() => _NewReferralState();
}

class _NewReferralState extends State<NewReferral> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    List<PlatformFile> _selectedFiles = [];
    Future<void> _pickFiles() async {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              appTitleCard(title: 'حالة تحويل جديدة'),
              const SizedBox(height: 22),

              // 2. قائمة المستخدمين
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E6ED)),
                  ),
                  child: Form(
                    child: ListView(
                      children: [
                        _buildTextField('ادخل رقم الهوية', label: 'رقم الهوية'),
                        _buildTextField(
                          'الاسم كامل',
                          isEnabled: false,
                          label: 'رقم الهوية',
                        ),
                        _buildTextField(
                          'ادخل رقم الهاتف ',
                          label: 'ادخل رقم الهاتف ',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          spacing: 15,

                          children: [
                            Expanded(
                              child: _buildTextField(
                                '01/09/2001',
                                isEnabled: false,
                              ),
                            ),
                            Expanded(
                              child: customDropdown(
                                selectedValue: _selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    value = _selectedValue;
                                  });
                                },
                                hint: 'نوع المرض',
                                items: ['القلب', 'العظام', 'الدماغ'],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),

                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFFE0E6ED)),
                          ),
                          child: Column(
                            children: [
                              // زر الاختيار
                              OutlinedButton(
                                onPressed: _pickFiles,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF23A455),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "اختيار ملف من الجهاز",
                                  style: TextStyle(
                                    color: Color(0xFF23A455),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // قائمة عرض الملفات المرفقة (كما في الصورة)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _selectedFiles.length,
                                itemBuilder: (context, index) {
                                  final file = _selectedFiles[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFD),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE8EEF5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // الحجم والنوع (يسار)
                                        Text(
                                          "${file.extension?.toUpperCase()} • ${(file.size / 1024 / 1024).toStringAsFixed(1)} MB",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        // اسم الملف (يمين)
                                        Text(
                                          file.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // زر استمرار للرفع فعلياً
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 32,
                            left: 20,
                            right: 20,
                          ),

                          width: double.infinity,
                          height: 55,
                          child: customButton(
                            text: 'استمرار',
                            onTap: () {
                              Navigator.of(context).pushNamed('secondReferral');
                            },
                          ),
                        ),
                      ],
                    ),
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

Widget _buildTextField(
  String hint, {
  Color? fillColor,
  bool isEnabled = true,
  String label = '',
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
      Visibility(
        visible: label.isEmpty ? false : true,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        margin: EdgeInsets.only(bottom: 12),
        child: TextField(
          enabled: isEnabled,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            fillColor: isEnabled ? fillColor ?? Colors.white : Colors.grey[200],
            // contentPadding: const EdgeInsets.only(bottom: 20),
          ),
        ),
      ),
    ],
  );
}
