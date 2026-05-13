import 'package:flutter/material.dart';

Widget textFiledWithLable({
  required String hint,
  required String lable,
  bool isPassword = false,
  bool isReadonly = false,
}) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          lable,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      loginTextFiled(
        hint: hint,
        isReadonly: isReadonly,
        isPassword: isPassword,
      ),
    ],
  );
}

Widget loginTextFiled({
  required String hint,
  bool isPassword = false,
  TextEditingController? controller,
  bool isReadonly = false,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    textAlign: TextAlign.right,
    // enabled: isReadonly,
    readOnly: isReadonly,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      // label: Text('data'),
      fillColor: isReadonly ? Color(0xffE7E5E5) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF1B9E4F)),
      ),
    ),
  );
}
