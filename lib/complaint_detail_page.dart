import 'package:flutter/material.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String complaintId;
  final Map<String, dynamic> complaintData;

  const ComplaintDetailPage({
    Key? key,
    required this.complaintId,
    required this.complaintData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complaint Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Complaint ID: $complaintId"),
            Text("Nature: ${complaintData['problemNature'] ?? 'N/A'}"),
            Text("Location: ${complaintData['location'] ?? 'N/A'}"),
            Text("Status: ${complaintData['status'] ?? 'N/A'}"),
            // Add more details here if needed
          ],
        ),
      ),
    );
  }
}
