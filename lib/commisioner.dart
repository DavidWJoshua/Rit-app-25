import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'junioreng.dart'; // Reusing the Complaint model from junioreng.dart

class CommissionerDashboard extends StatefulWidget {
  const CommissionerDashboard({super.key});

  @override
  _CommissionerDashboardState createState() => _CommissionerDashboardState();
}

class _CommissionerDashboardState extends State<CommissionerDashboard> {
  Future<List<Complaint>>? _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _fetchAllComplaints();
  }

  Future<List<Complaint>> _fetchAllComplaints() async {
    final response = await http.get(Uri.parse('http://localhost:3000/complaints'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> complaintsJson = data['complaints'];
      return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commissioner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout functionality
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Complaints Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildComplaintsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsList() {
    return FutureBuilder<List<Complaint>>(
      future: _complaintsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No complaints found.'));
        }

        // Sort complaints to show escalated and pending ones first
        final sortedComplaints = snapshot.data!;
        sortedComplaints.sort((a, b) {
          // Prioritize escalated complaints
          if (a.status.contains('Escalated') && !b.status.contains('Escalated')) {
            return -1;
          }
          if (!a.status.contains('Escalated') && b.status.contains('Escalated')) {
            return 1;
          }
          // Prioritize pending complaints
          if (a.status == 'Submitted' && b.status != 'Submitted') {
            return -1;
          }
          if (a.status != 'Submitted' && b.status == 'Submitted') {
            return 1;
          }
          // Sort by creation date in descending order for other complaints
          return b.createdAt.compareTo(a.createdAt);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedComplaints.length,
          itemBuilder: (context, index) {
            final complaint = sortedComplaints[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text('Complaint ID: ${complaint.id}'),
                subtitle: Text(
                  'Problem: ${complaint.problemNature}\nLocation: ${complaint.location}\nStatus: ${complaint.status}'
                ),
                trailing: Text(
                  'Escalation: ${complaint.escalationCount}',
                  style: TextStyle(
                    color: complaint.escalationCount > 0 ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // TODO: Navigate to a detailed view of the complaint
                },
              ),
            );
          },
        );
      },
    );
  }
}