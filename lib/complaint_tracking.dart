import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your newly created ComplaintDetailPage here
import 'package:civil_project/complaint_detail_page.dart'; // adjust path accordingly

class ComplaintTrackingPage extends StatelessWidget {
  final String? userPhoneNumber;

  const ComplaintTrackingPage({Key? key, this.userPhoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? currentUserPhone = userPhoneNumber ?? FirebaseAuth.instance.currentUser?.phoneNumber;

    return Scaffold(
      appBar: AppBar(title: const Text("Complaint Tracking")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Complaints")
            .where("complainantPhone", isEqualTo: currentUserPhone)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No complaints submitted yet."),
            );
          }
          final complaints = snapshot.data!.docs;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final data = complaints[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.red),
                  title: Text(data["problemNature"] ?? "Unknown Problem"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Location: ${data["location"] ?? "N/A"}"),
                      Text("Status: ${data["status"] ?? "Pending"}"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailPage(
                          complaintId: complaints[index].id,
                          complaintData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
