import 'package:flutter/material.dart';
import 'package:pet_clean/models/alert_model.dart';

class AlertDetailPage extends StatelessWidget {
  final AlertModel alert;

  const AlertDetailPage({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alert.title),
      ),
      body: Column(
        children: [
          Text(alert.description),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
