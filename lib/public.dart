import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:civil_project/complain.dart'; // complaint form page
import 'package:civil_project/complaint_tracking.dart'; // complaint tracking page

class PublicDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Complaint'),
                subtitle: const Text('Click to fill complaint details'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ComplaintFormPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Dashboard'),
                subtitle: const Text('Track complaint process'),
                onTap: () {
                  // Get current user's phone number (for OTP login, this is set)
                  String? userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ComplaintTrackingPage(userPhoneNumber: userPhone),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
