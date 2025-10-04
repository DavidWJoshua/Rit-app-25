class LpEntry {
  DateTime date;
  String username, role, pumpingStatus, pumpLeakage, taskCompleted;
  double currentValue;

  LpEntry({
    required this.date,
    required this.username,
    required this.role,
    required this.pumpingStatus,
    required this.currentValue,
    required this.pumpLeakage,
    required this.taskCompleted,
  });

  factory LpEntry.fromMap(Map<String, dynamic> data) {
    return LpEntry(
      date: data['date'].toDate(),
      username: data['username'],
      role: data['role'],
      pumpingStatus: data['pumping_status'],
      currentValue: data['current_value']?.toDouble() ?? 0,
      pumpLeakage: data['pump_leakage'],
      taskCompleted: data['task_completed'],
    );
  }
  Map<String, dynamic> toMap() => {
    'date': date,
    'username': username,
    'role': role,
    'pumping_status': pumpingStatus,
    'current_value': currentValue,
    'pump_leakage': pumpLeakage,
    'task_completed': taskCompleted,
  };
}
