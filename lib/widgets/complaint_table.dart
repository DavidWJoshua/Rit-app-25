import 'package:flutter/material.dart';
class ComplaintTable extends StatelessWidget {
  final List complaints;
  ComplaintTable({required this.complaints});
  @override
  Widget build(BuildContext context) => DataTable(
        columns: [DataColumn(label: Text("Date")), DataColumn(label: Text("Name")), DataColumn(label: Text("Status"))],
        rows: complaints.map((c) => DataRow(cells: [
              DataCell(Text("${c.date}")),
              DataCell(Text(c.complaintName)),
              DataCell(Text(c.status)),
            ])).toList(),
      );
}
