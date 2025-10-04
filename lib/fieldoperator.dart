import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FieldTeamDashboard extends StatefulWidget {
  final String userId; // ID of the field operator (user)

  const FieldTeamDashboard({Key? key, required this.userId, required AppUser user}) : super(key: key);

  @override
  _FieldTeamDashboardState createState() => _FieldTeamDashboardState();
}

class AppUser {
  // Define this class as needed for user data (optional)
}

class _FieldTeamDashboardState extends State<FieldTeamDashboard> {
  Future<List<Complaint>>? _complaintsFuture;

  int totalAssigned = 0;
  int pending = 0;
  int inProgress = 0;
  int escalated = 0;
  int overdue = 0;

  @override
  void initState() {
    super.initState();
    _complaintsFuture = _fetchComplaints();
  }

  Future<List<Complaint>> _fetchComplaints() async {
    final response = await http.get(
      Uri.parse('http://192.168.31.100:3000/api/complaints/assigned/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final complaints = data.map((json) => Complaint.fromJson(json)).toList();
      _updateMetrics(complaints);
      return complaints;
    } else {
      throw Exception('Failed to load complaints');
    }
  }

  void _updateMetrics(List<Complaint> complaints) {
    setState(() {
      totalAssigned = complaints.length;
      pending = complaints.where((c) => c.status == 'Pending').length;
      inProgress = complaints.where((c) => c.status == 'In Progress').length;
      escalated = complaints.where((c) => c.status == 'Escalated').length;
      overdue = complaints.where((c) => _isOverdue(c)).length;
    });
  }

  bool _isOverdue(Complaint complaint) {
    final deadline = complaint.createdAt.add(const Duration(hours: 24));
    return DateTime.now().isAfter(deadline) && complaint.status != 'Resolved';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMetricsGrid(),
            const SizedBox(height: 20),
            _buildActiveComplaintsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Complaints Assigned to You',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricCard('Total', totalAssigned, Colors.blue),
        _buildMetricCard('Pending', pending, Colors.orange),
        _buildMetricCard('In Progress', inProgress, Colors.cyan),
        _buildMetricCard('Escalated', escalated, Colors.red),
        _buildMetricCard('Overdue', overdue, Colors.red),
      ],
    );
  }

  Widget _buildMetricCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveComplaintsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Complaints',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Complaint>>(
          future: _complaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No active complaints assigned.'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final complaint = snapshot.data![index];
                return _buildComplaintCard(complaint);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${complaint.id.substring(0, 8)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              complaint.natureOfProblem,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(complaint.location),
            const SizedBox(height: 8),
            Text('Assigned to: ${complaint.assignedTo}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement View Details
                  },
                  child: const Text('View Details'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Mark Resolved
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Mark Resolved'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Complaint {
  final String id;
  final String natureOfProblem;
  final String location;
  final String assignedTo;
  final String status;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.natureOfProblem,
    required this.location,
    required this.assignedTo,
    required this.status,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      natureOfProblem: json['nature_of_problem'],
      location: json['location'],
      assignedTo: json['assigned_to'] ?? 'N/A',
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
