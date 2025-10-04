class Complaint {
  String id, complaintName, description, address, location, phoneNo, natureOfProblem, impact, evidenceFileUrl, control, status;
  DateTime date;
  String startTime, timeDuration;

  Complaint({
    required this.id,
    required this.complaintName,
    required this.description,
    required this.address,
    required this.location,
    required this.phoneNo,
    required this.natureOfProblem,
    required this.startTime,
    required this.timeDuration,
    required this.impact,
    required this.evidenceFileUrl,
    required this.date,
    required this.control,
    required this.status,
  });

  factory Complaint.fromMap(String id, Map<String, dynamic> data) {
    return Complaint(
      id: id,
      complaintName: data['complaint_name'],
      description: data['description'],
      address: data['address'],
      location: data['location'],
      phoneNo: data['phone_no'],
      natureOfProblem: data['nature_of_problem'],
      startTime: data['start_time'],
      timeDuration: data['time_duration'],
      impact: data['impact'],
      evidenceFileUrl: data['evidence_file_url'],
      date: data['date'].toDate(),
      control: data['control'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() => {
    "complaint_name": complaintName,
    "description": description,
    "address": address,
    "location": location,
    "phone_no": phoneNo,
    "nature_of_problem": natureOfProblem,
    "start_time": startTime,
    "time_duration": timeDuration,
    "impact": impact,
    "evidence_file_url": evidenceFileUrl,
    "date": date,
    "control": control,
    "status": status,
  };
}
