import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  CustomTextField({required this.label, required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, decoration: InputDecoration(labelText: label));
  }
}
