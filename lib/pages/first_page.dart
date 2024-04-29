import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

final supabase = Supabase.instance.client;

class _FirstPageState extends State<FirstPage> {
  late final TextEditingController _nombreController = TextEditingController();
  late final TextEditingController _apellidosController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User ID: ${supabase.auth.currentUser!.id}'),
            Text('Email: ${supabase.auth.currentUser!.email}'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _apellidosController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
                onPressed: _enviarDatosUsuario,
                child: const Text('Enviar Datos'))
          ],
        ),
      ),
    );
  }

  void _enviarDatosUsuario() async {
    final nombre = _nombreController.text;
    final apellidos = _apellidosController.text;

    if (nombre.isEmpty || apellidos.isEmpty) {
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      return;
    }

    final data = {
      'user_id': user.id,
      'nombre': nombre,
      'apellidos': apellidos,
    };

    final response =
        await supabase.from('users').select().eq('user_id', user.id);

    if (response.isNotEmpty) {
      // Si existe un registro con el user_id dado, actualiza ese registro.
      await supabase.from('users').update(data).eq('user_id', user.id);
    } else {
      // Si no existe un registro con el user_id dado, inserta un nuevo registro.
      await supabase.from('users').insert(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos guardados correctamente'),
      ),
    );
  }
}
