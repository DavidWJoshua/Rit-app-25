// commisioner.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfficerCommissioner extends StatefulWidget {
  const OfficerCommissioner({super.key});
  @override
  State<OfficerCommissioner> createState() => _OfficerCommissionerState();
}

class _OfficerCommissionerState extends State<OfficerCommissioner> {
  String _filter = "notCompleted";
  Stream<QuerySnapshot>? _tasksStream;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    Query query = FirebaseFirestore.instance.collection('complaint');
    if (_filter == "completed") {
      query = query.where('control', isEqualTo: 'Commissioner').where('status', isEqualTo: 'Completed');
    } else if (_filter == "toDo") {
      query = query.where('control', isEqualTo: 'Commissioner').where('status', isEqualTo: 'Pending');
    } else {
      query = query.where('control', isEqualTo: 'Commissioner').where('status', isEqualTo: 'Not Completed');
    }
    setState(() {
      _tasksStream = query.snapshots();
    });
  }

  void _setFilter(String filter) {
    setState(() => _filter = filter);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Commissioner!")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () => _setFilter("completed"), child: const Text("Completed Tasks")),
              TextButton(onPressed: () => _setFilter("notCompleted"), child: const Text("Not Completed")),
              TextButton(onPressed: () => _setFilter("toDo"), child: const Text("To Do List")),
            ],
          ),
          Expanded(
            child: _tasksStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _tasksStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No tasks"));
                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['complaint_name'] ?? ''),
                            subtitle: Text("Date: ${data['date']?.toDate().toString().split(' ')[0] ?? 'N/A'}\nLocation: ${data['location'] ?? ''}"),
                            trailing: TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: Text(data['complaint_name'] ?? "Details"),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: data.entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))
                                          ],
                                        );
                                      });
                                },
                                child: const Text("Details")),
                          );
                        }).toList(),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
