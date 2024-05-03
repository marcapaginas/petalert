import 'package:flutter/material.dart';
import 'package:pet_clean/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

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
          )),
          ElevatedButton.icon(
            onPressed: () => _signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          )
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.amber,
      );
    } catch (error) {
      const SnackBar(
        content: Text('Error inesperado al salir.'),
        backgroundColor: Colors.amber,
      );
    }
  }
}
