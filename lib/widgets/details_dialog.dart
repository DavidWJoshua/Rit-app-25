import 'package:flutter/material.dart';
detailsDialog(BuildContext context, String title, List<String> fields) async {
  await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(title),
            content: Column(mainAxisSize: MainAxisSize.min, children: fields.map((f) => Text(f)).toList()),
            actions: [TextButton(child: Text("Close"), onPressed: () => Navigator.pop(context))],
          ));
}
