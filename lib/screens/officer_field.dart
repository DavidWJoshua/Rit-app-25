import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class OfficerField extends StatefulWidget {
  const OfficerField({super.key});
  @override
  State<OfficerField> createState() => _OfficerFieldState();
}

class _OfficerFieldState extends State<OfficerField> {
  String _filter = "notCompleted";
  Stream<QuerySnapshot>? _tasksStream;
  Map<String, PlatformFile?> _selectedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    Query query = FirebaseFirestore.instance.collection('complaint');
    if (_filter == "completed") {
      query = query.where('control', isEqualTo: 'FieldOfficer').where('status', isEqualTo: 'Completed');
    } else if (_filter == "toDo") {
      query = query.where('control', isEqualTo: 'FieldOfficer').where('status', isEqualTo: 'Pending');
    } else {
      query = query.where('control', isNotEqualTo: 'FieldOfficer');
    }
    setState(() {
      _tasksStream = query.snapshots();
    });
  }

  void _setFilter(String filter) {
    setState(() => _filter = filter);
    _loadTasks();
  }

  Future<void> _pickFile(String docId) async {
    final result = await FilePicker.platform.pickFiles(
      withData: true, // get file bytes for upload
    );

    if (result != null && result.files.single.size <= 10 * 1024 * 1024) {
      setState(() {
        _selectedFiles[docId] = result.files.single;
      });
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File too large. Max 10 MB allowed.")),
      );
    }
  }

  Future<void> _submitFileAndComplete(String docId) async {
    if (docId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid complaint document ID")),
      );
      return;
    }

    final file = _selectedFiles[docId];
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first")),
      );
      return;
    }

    final storageRef = FirebaseStorage.instance.ref().child('complaint_files/$docId/${file.name}');

    try {
      if (file.bytes != null) {
        await storageRef.putData(file.bytes!);
      } else if (file.path != null) {
        final localFile = File(file.path!);
        await storageRef.putFile(localFile);
      } else {
        throw Exception("No file bytes or path available");
      }

      final downloadUrl = await storageRef.getDownloadURL();

      final docRef = FirebaseFirestore.instance.collection('complaint').doc(docId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception("Complaint document not found");
      }

      await docRef.update({
        'status': 'Completed',
        'file_url': downloadUrl,
      });

      _loadTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded and marked as Completed.")),
      );

      setState(() {
        _selectedFiles.remove(docId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Field Officer!")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _setFilter("completed"),
                child: const Text("Completed Tasks"),
              ),
              TextButton(
                onPressed: () => _setFilter("notCompleted"),
                child: const Text("Not Completed"),
              ),
              TextButton(
                onPressed: () => _setFilter("toDo"),
                child: const Text("To Do List"),
              ),
            ],
          ),
          Expanded(
            child: _tasksStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _tasksStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No tasks"));
                      }

                      if (_filter == "toDo") {
                        return ListView(
                          padding: const EdgeInsets.all(8),
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final docId = doc.id;
                            final dateStr = data['date']?.toDate().toString().split(' ')[0] ?? 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(dateStr, overflow: TextOverflow.ellipsis),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(data['complaint_name'] ?? '', overflow: TextOverflow.ellipsis),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(data['location'] ?? '', overflow: TextOverflow.ellipsis),
                                        ),
                                        TextButton(
                                          child: const Text("Details"),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
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
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _pickFile(docId),
                                          child: Text(_selectedFiles[docId]?.name ?? 'Select File'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () => _submitFileAndComplete(docId),
                                          child: const Text("Submit"),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['complaint_name'] ?? ''),
                            subtitle: Text(
                              "Date: ${data['date']?.toDate().toString().split(' ')[0] ?? 'N/A'}\nLocation: ${data['location'] ?? ''}",
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(data['complaint_name'] ?? "Details"),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: data.entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text("Details"),
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
