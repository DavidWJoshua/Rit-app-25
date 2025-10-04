// stp_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StpPage extends StatefulWidget {
  const StpPage({super.key});
  @override
  State<StpPage> createState() => _StpPageState();
}

class _StpPageState extends State<StpPage> {
  final TextEditingController _bodController = TextEditingController();
  final TextEditingController _codController = TextEditingController();
  final TextEditingController _inflowController = TextEditingController();
  final TextEditingController _outflowController = TextEditingController();
  final TextEditingController _overallSafetyController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitData() async {
    setState(() => _isSubmitting = true);

    double? bod = double.tryParse(_bodController.text.trim());
    double? cod = double.tryParse(_codController.text.trim());
    double? inflow = double.tryParse(_inflowController.text.trim());
    double? outflow = double.tryParse(_outflowController.text.trim());
    String overallSafety = _overallSafetyController.text.trim();

    String taskCompleted = "Not Started";

    if (bod != null && cod != null && inflow != null && outflow != null && overallSafety.isNotEmpty) {
      taskCompleted = "Completed";
    } else if (bod != null || cod != null || inflow != null || outflow != null || overallSafety.isNotEmpty) {
      taskCompleted = "Pending";
    }

    await FirebaseFirestore.instance.collection('stp').add({
      'date': FieldValue.serverTimestamp(),
      'username': "stpUser", // Replace with current logged in user
      'bod': bod ?? 0.0,
      'cod': cod ?? 0.0,
      'inflow': inflow ?? 0.0,
      'outflow': outflow ?? 0.0,
      'overall_safety': overallSafety,
      'task_completed': taskCompleted,
    });

    setState(() {
      _isSubmitting = false;
      _bodController.clear();
      _codController.clear();
      _inflowController.clear();
      _outflowController.clear();
      _overallSafetyController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data submitted successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("STP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _bodController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "BOD (Float)"),
              ),
              TextField(
                controller: _codController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "COD (Float)"),
              ),
              TextField(
                controller: _inflowController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Inflow (Float)"),
              ),
              TextField(
                controller: _outflowController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Outflow (Float)"),
              ),
              TextField(
                controller: _overallSafetyController,
                decoration: const InputDecoration(labelText: "Overall Safety (String)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
