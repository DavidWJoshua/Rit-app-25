// lifting_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiftingPage extends StatefulWidget {
  const LiftingPage({super.key});
  @override
  State<LiftingPage> createState() => _LiftingPageState();
}

class _LiftingPageState extends State<LiftingPage> {
  final TextEditingController _pumpingStatusController = TextEditingController();
  final TextEditingController _currentValueController = TextEditingController();
  final TextEditingController _pumpLeakageController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitData() async {
    setState(() => _isSubmitting = true);

    String pumpingStatus = _pumpingStatusController.text.trim();
    String pumpLeakage = _pumpLeakageController.text.trim();
    double? currentVal = double.tryParse(_currentValueController.text.trim());

    String taskCompleted = "Not Started";
    if (pumpingStatus.isNotEmpty && currentVal != null && pumpLeakage.isNotEmpty) {
      taskCompleted = "Completed";
    } else if (pumpingStatus.isNotEmpty || currentVal != null || pumpLeakage.isNotEmpty) {
      taskCompleted = "Pending";
    }

    await FirebaseFirestore.instance.collection('lp').add({
      'date': FieldValue.serverTimestamp(),
      'username': "liftingUser", // Replace with current login user
      'role': "Lifting",
      'pumping_status': pumpingStatus,
      'current_value': currentVal ?? 0.0,
      'pump_leakage': pumpLeakage,
      'task_completed': taskCompleted,
    });

    setState(() {
      _isSubmitting = false;
      _pumpingStatusController.clear();
      _currentValueController.clear();
      _pumpLeakageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data submitted successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lifting")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pumpingStatusController,
              decoration: const InputDecoration(labelText: "Pumping Status"),
            ),
            TextField(
              controller: _currentValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Current Value (Float)"),
            ),
            TextField(
              controller: _pumpLeakageController,
              decoration: const InputDecoration(labelText: "Pump Leakage"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitData,
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
