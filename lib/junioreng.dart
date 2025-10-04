import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Complaint {
  final int id;
  final String complainant;
  final String problemNature;
  final String location;
  final String status;
  final int escalationCount;
  final String? assignedToUserId;
  final DateTime createdAt;
  final DateTime? assignedAt;

  Complaint({
    required this.id,
    required this.complainant,
    required this.problemNature,
    required this.location,
    required this.status,
    required this.escalationCount,
    this.assignedToUserId,
    required this.createdAt,
    this.assignedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      complainant: json['complainant'] ?? 'Unknown',
      problemNature: json['problem_nature'] ?? 'Not specified',
      location: json['location'] ?? 'Not given',
      status: json['status'] ?? 'Unknown',
      escalationCount: json['escalation_count'] ?? 0,
      assignedToUserId: json['assigned_to_user_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      assignedAt: json['assigned_at'] != null ? DateTime.tryParse(json['assigned_at']) : null,
    );
  }
}

class JuniorEngDashboard extends StatefulWidget {
  const JuniorEngDashboard({super.key});

  @override
  _JuniorEngDashboardState createState() => _JuniorEngDashboardState();
}

class _JuniorEngDashboardState extends State<JuniorEngDashboard> {
  Future<List<Complaint>>? _complaintsFuture;
  String _filter = 'all'; // Default filter if you want to add one

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _fetchComplaints();
  }

  Future<List<Complaint>> _fetchComplaints() async {
    final response = await http.get(Uri.parse('http://localhost:3000/complaints'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> complaintsJson = data['complaints'] ?? [];
      print("Fetched complaints count: ${complaintsJson.length}");
      return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
      // Optionally implement filter reset or refresh logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Junior Engineer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      onPressed: () => _setFilter("completed"),
                      child: const Text("Completed Tasks", textAlign: TextAlign.center),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      onPressed: () => _setFilter("notCompleted"),
                      child: const Text("Not Completed", textAlign: TextAlign.center),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      onPressed: () => _setFilter("toDo"),
                      child: const Text("To Do List", textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Complaint>>(
                future: _complaintsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No complaints found.'));
                  }

                  var complaints = snapshot.data!;

                  // Apply your filter logic here based on _filter state
                  List<Complaint> filteredComplaints;
                  switch (_filter) {
                    case "completed":
                      filteredComplaints = complaints.where((c) => c.status.toLowerCase() == 'completed').toList();
                      break;
                    case "notCompleted":
                      filteredComplaints = complaints.where((c) => c.status.toLowerCase() != 'completed').toList();
                      break;
                    case "toDo":
                      filteredComplaints = complaints.where((c) => c.status.toLowerCase() == 'pending').toList();
                      break;
                    default:
                      filteredComplaints = complaints;
                  }

                  if (filteredComplaints.isEmpty) {
                    return const Center(child: Text('No complaints found for this filter.'));
                  }

                  return ListView.separated(
                    itemCount: filteredComplaints.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final complaint = filteredComplaints[index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.report_problem, color: Colors.orange),
                          title: Text(
                            'ID: ${complaint.id} | ${complaint.problemNature}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${complaint.location}'),
                              Text('Status: ${complaint.status}'),
                              Text('Escalation: ${complaint.escalationCount}'),
                              if (complaint.assignedToUserId != null)
                                Text('Assigned to: ${complaint.assignedToUserId!}'),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[700]),
                          onTap: () {
                            // TODO: Navigate to complaint detail page if needed
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
