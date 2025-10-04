import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User
  Future<void> addUser(String phoneNumber) async {
    await _db.collection('users').doc(phoneNumber).set({'phonenumber': phoneNumber});
  }

  // Complaint
  Future<void> addComplaint(Map<String, dynamic> data) async {
    await _db.collection('complaint').add(data);
  }

  // LP
  Future<void> addLpEntry(Map<String, dynamic> data) async {
    await _db.collection('lp').add(data);
  }

  // STP
  Future<void> addStpEntry(Map<String, dynamic> data) async {
    await _db.collection('stp').add(data);
  }

  Stream<QuerySnapshot> getComplaintsByControlAndStatus(String control, String status) {
    return _db.collection('complaint').where('control', isEqualTo: control).where('status', isEqualTo: status).snapshots();
  }

  /// Escalates complaints that are pending past 2-minute thresholds.
  Future<void> escalatePendingComplaints() async {
    final now = DateTime.now();

    // Fetch all complaints with status 'Pending'
    QuerySnapshot snapshot = await _db.collection('complaint').where('status', isEqualTo: 'Pending').get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final control = data['control'] as String? ?? '';
      final Timestamp? dateTimestamp = data['date'] as Timestamp?;
      final Timestamp? controlChangedTimestamp = data['control_changed_date'] as Timestamp?;

      // Reference date for elapsed time check
      DateTime referenceDate;

      if (control == 'FieldOfficer') {
        if (dateTimestamp == null) continue;
        referenceDate = dateTimestamp.toDate();
        final diffMinutes = now.difference(referenceDate).inMinutes;
        if (diffMinutes >= 2) {
          // Escalate to JuniorEngineer
          await doc.reference.update({
            'control': 'JuniorEngineer',
            'control_changed_date': Timestamp.now(),
          });
        }
      } else if (control == 'JuniorEngineer') {
        if (controlChangedTimestamp == null) continue;
        referenceDate = controlChangedTimestamp.toDate();
        final diffMinutes = now.difference(referenceDate).inMinutes;
        if (diffMinutes >= 2) {
          // Escalate to Commissioner
          await doc.reference.update({
            'control': 'Commissioner',
            'control_changed_date': Timestamp.now(),
          });
        }
      }
      // If control is 'Commissioner' no further escalation
    }
  }

  // add further CRUD methods as necessary
}
