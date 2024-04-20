import 'package:flutter/material.dart';

class AlertDetail extends StatelessWidget {
  const AlertDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerta 1'),
      ),
      body: Column(
        children: [
          const Text('Descripcion de la alerta 1'),
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
