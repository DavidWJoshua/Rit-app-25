// admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedFilter = "Lifting";
  Stream<QuerySnapshot>? _dataStream;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    late Query q;
    if (_selectedFilter == "Lifting") {
      q = FirebaseFirestore.instance.collection('lp').where('role', isEqualTo: 'Lifting');
    } else if (_selectedFilter == "Pumping") {
      q = FirebaseFirestore.instance.collection('lp').where('role', isEqualTo: 'Pumping');
    } else {
      q = FirebaseFirestore.instance.collection('stp');
    }
    setState(() {
      _dataStream = q.snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedFilter,
              items: <String>['Lifting', 'Pumping', 'Stp'].map((String val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedFilter = val;
                    _loadData();
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _dataStream == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _dataStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No data"));
                        return DataTable(
                          columns: const [
                            DataColumn(label: Text("Date")),
                            DataColumn(label: Text("Username")),
                            DataColumn(label: Text("Task Completed")),
                          ],
                          rows: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final dateTimestamp = data['date'] as Timestamp?;
                            final dateString = dateTimestamp != null ? dateTimestamp.toDate().toString().split(" ")[0] : "";
                            return DataRow(cells: [
                              DataCell(Text(dateString)),
                              DataCell(Text(data['username'] ?? '')),
                              DataCell(Text(data['task_completed'] ?? '')),
                            ]);
                          }).toList(),
                        );
                      }),
            )
          ],
        ),
      ),
    );
  }
}
