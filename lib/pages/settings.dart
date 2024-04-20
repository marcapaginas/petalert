import 'package:flutter/material.dart';
import 'package:pet_clean/services/notification_service.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                NotificationService.show(title: 'Notificacion', body: 'Hola');
              },
              child: const Text('Notificacion')),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Notificaciones:'),
              ElevatedButton(
                  onPressed: () =>
                      NotificationService.sendPeriodicNotification(),
                  child: const Text('activar notis')),
              ElevatedButton(
                  onPressed: () =>
                      NotificationService.cancelPeriodicNotifications(),
                  child: const Text('desactivar notis')),
            ],
          ))
        ],
      ),
    );
  }
}
