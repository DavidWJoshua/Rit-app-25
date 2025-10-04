import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintStatus extends StatefulWidget {
  const ComplaintStatus({super.key});

  @override
  State<ComplaintStatus> createState() => _ComplaintStatusState();
}

class _ComplaintStatusState extends State<ComplaintStatus> {
  late final String? _userPhoneNumber;
  Stream<QuerySnapshot>? _complaintStream;

  @override
  void initState() {
    super.initState();
    // Get logged-in user phone number from Firebase Auth
    _userPhoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
    if (_userPhoneNumber != null) {
      // Listen for complaints of this user
      _complaintStream = FirebaseFirestore.instance
          .collection('complaint')
          .where('phone_no', isEqualTo: _userPhoneNumber)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Complaint Status")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: _userPhoneNumber == null
            ? const Center(
                child: Text(
                  "No logged-in user phone number found.\nPlease login first.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: _complaintStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No complaints found"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(data['complaint_name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Location: ${data['location'] ?? ''}"),
                              Text("Status: ${data['status'] ?? ''}"),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
      ),
    );
  }
}
