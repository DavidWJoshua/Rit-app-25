// complaint_form.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintForm extends StatefulWidget {
  ComplaintForm({super.key});
  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _complaintName = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _phoneNo = TextEditingController();
  String _natureOfProblem = 'breakage';
  TextEditingController _startTime = TextEditingController();
  TextEditingController _timeDuration = TextEditingController();
  TextEditingController _impact = TextEditingController();

  XFile? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxHeight: 800, maxWidth: 800, imageQuality: 70);
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  Future<String?> _uploadFile(File file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
    Reference ref = FirebaseStorage.instance.ref().child('evidences').child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    String? fileUrl;
    if (_selectedImage != null) {
      fileUrl = await _uploadFile(File(_selectedImage!.path));
    }

    await FirebaseFirestore.instance.collection('complaint').add({
      'complaint_name': _complaintName.text.trim(),
      'description': _description.text.trim(),
      'address': _address.text.trim(),
      'location': _location.text.trim(),
      'phone_no': _phoneNo.text.trim(),
      'nature_of_problem': _natureOfProblem,
      'start_time': _startTime.text.trim(),
      'time_duration': _timeDuration.text.trim(),
      'impact': _impact.text.trim(),
      'evidence_file_url': fileUrl ?? '',
      'date': FieldValue.serverTimestamp(),
      'control': 'FieldOfficer',
      'status': 'Pending',
    });

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Complaint submitted successfully")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Raise Complaint")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _complaintName, decoration: const InputDecoration(labelText: "Complaint Name"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: _description, decoration: const InputDecoration(labelText: "Description"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: _address, decoration: const InputDecoration(labelText: "Address"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: _location, decoration: const InputDecoration(labelText: "Location"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(
                controller: _phoneNo,
                decoration: const InputDecoration(labelText: "Phone No"),
                validator: (v) => v!.isEmpty || !RegExp(r'^\+91\d{10}$').hasMatch(v) ? "Valid Indian phone required" : null,
              ),
              DropdownButtonFormField(
                value: _natureOfProblem,
                decoration: const InputDecoration(labelText: "Nature of Problem"),
                items: const [
                  DropdownMenuItem(value: 'breakage', child: Text("Breakage")),
                  DropdownMenuItem(value: 'overflow', child: Text("Overflow")),
                ],
                onChanged: (String? val) {
                  if (val != null) setState(() => _natureOfProblem = val);
                },
              ),
              TextFormField(controller: _startTime, decoration: const InputDecoration(labelText: "Start Time"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: _timeDuration, decoration: const InputDecoration(labelText: "Time Duration"), validator: (v) => v!.isEmpty ? "Required" : null),
              TextFormField(controller: _impact, decoration: const InputDecoration(labelText: "Impact"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 10),
              _selectedImage == null ? Text("No image selected") : Image.file(File(_selectedImage!.path), height: 120),
              ElevatedButton(onPressed: _pickImage, child: const Text("Upload Image for Evidence")),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
