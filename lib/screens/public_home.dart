// public_home.dart
import 'package:flutter/material.dart';
import 'complaint_form.dart';
import 'complaint_status.dart';

class PublicHome extends StatelessWidget {
  const PublicHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("navigation.in")),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComplaintForm())),
              child: Card(
                color: Colors.indigo.shade100,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(child: Text("Raise complaint", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900))),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintStatus())),
              child: Card(
                color: Colors.indigo.shade100,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(child: Text("Check status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
