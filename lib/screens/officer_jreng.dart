import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfficerJrEng extends StatefulWidget {
  const OfficerJrEng({super.key});
  @override
  State<OfficerJrEng> createState() => _OfficerJrEngState();
}

class _OfficerJrEngState extends State<OfficerJrEng> {
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
      query = query.where('control', isEqualTo: 'JuniorEngineer').where('status', isEqualTo: 'Completed');
    } else if (_filter == "toDo") {
      query = query.where('control', isEqualTo: 'JuniorEngineer').where('status', isEqualTo: 'Pending');
    } else {
      query = query.where('control', whereNotIn: ['JuniorEngineer', 'FieldOfficer']);
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
      appBar: AppBar(title: const Text("Welcome Junior Engineer!")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
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
                            subtitle: Text(
                              "Date: ${data['date']?.toDate().toString().split(' ')[0] ?? 'N/A'}\nLocation: ${data['location'] ?? ''}",
                            ),
                            trailing: TextButton(
                              child: const Text("Details"),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: Text(data['complaint_name'] ?? "Details"),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: data.entries
                                              .map((e) => Text("${e.key}: ${e.value}"))
                                              .toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text("Close"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
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
