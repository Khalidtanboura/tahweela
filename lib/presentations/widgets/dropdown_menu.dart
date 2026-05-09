import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customDropdown({
  required String hint,
  required List<String> items,
  String? selectedValue,
  void Function(String?)? onChanged,
  bool isEnabled = true,
}) {
  return DropdownButtonFormField<String>(
    items: items.map((String value) {
      return DropdownMenuItem(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.black),
        ),
        value: value,
      );
    }).toList(),
    value: selectedValue,
    onChanged: isEnabled ? onChanged : null,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      // تظليل الخلفية إذا كانت القائمة معطلة
      fillColor: isEnabled ? Colors.white : const Color(0xFFDCDCDC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    ),
    // أيقونة السهم
    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
    dropdownColor: Colors.white,
    isExpanded: true,
    // لضمان أخذ العرض بالكامل
    hint: Text(hint, style: const TextStyle(color: Colors.grey)),
    isDense: true,
  );
}
