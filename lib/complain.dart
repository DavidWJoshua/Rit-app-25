import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({super.key});

  @override
  _ComplaintFormPageState createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _complainantNameController = TextEditingController();
  final TextEditingController _complainantPhoneController = TextEditingController();
  final TextEditingController _problemNatureController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _impactController = TextEditingController();
  XFile? _proof;
  bool _submitting = false;

  Future<void> _pickProof() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _proof = picked);
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    String proofUrl = '';
    if (_proof != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("complaint_proofs/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await storageRef.putData(await _proof!.readAsBytes());
      proofUrl = await storageRef.getDownloadURL();
    }

    final complaintData = {
  'complainantName': _complainantNameController.text,
  // instead of user-typed value:
  // 'complainantPhone': _complainantPhoneController.text,
  'complainantPhone': FirebaseAuth.instance.currentUser?.phoneNumber, // This is the fix!
  'problemNature': _problemNatureController.text,
  'description': _descriptionController.text,
  'location': _locationController.text,
  'startTime': _startTimeController.text,
  'impact': _impactController.text,
  'proofImageUrl': proofUrl,
  'status': 'Pending',
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
};


    try {
      await FirebaseFirestore.instance.collection("Complaints").add(complaintData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Complaint')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _complainantNameController,
                decoration: const InputDecoration(labelText: 'Complainant Name'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _complainantPhoneController,
                decoration: const InputDecoration(labelText: 'Complainant Phone'),
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _problemNatureController,
                decoration: const InputDecoration(labelText: 'Nature of Problem'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter problem nature' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 5,
                validator: (val) => val == null || val.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location (Coordinates/Address)'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _startTimeController,
                decoration: const InputDecoration(labelText: 'Start Time'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter start time' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _impactController,
                decoration: const InputDecoration(labelText: 'Impact'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter impact' : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Proof (Take photo)'),
                subtitle: Text(_proof == null ? 'No photo attached' : 'Photo attached: ${_proof!.name}'),
                trailing: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickProof,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitComplaint,
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Complaint'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
