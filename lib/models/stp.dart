class StpEntry {
  DateTime date;
  String username, overallSafety, taskCompleted;
  double bod, cod, inflow, outflow;

  StpEntry({
    required this.date,
    required this.username,
    required this.bod,
    required this.cod,
    required this.inflow,
    required this.outflow,
    required this.overallSafety,
    required this.taskCompleted,
  });

  factory StpEntry.fromMap(Map<String, dynamic> data) {
    return StpEntry(
      date: data['date'].toDate(),
      username: data['username'],
      bod: data['bod']?.toDouble() ?? 0,
      cod: data['cod']?.toDouble() ?? 0,
      inflow: data['inflow']?.toDouble() ?? 0,
      outflow: data['outflow']?.toDouble() ?? 0,
      overallSafety: data['overall_safety'],
      taskCompleted: data['task_completed'],
    );
  }
  Map<String, dynamic> toMap() => {
    'date': date,
    'username': username,
    'bod': bod,
    'cod': cod,
    'inflow': inflow,
    'outflow': outflow,
    'overall_safety': overallSafety,
    'task_completed': taskCompleted,
  };
}
