import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Registrar un nuevo usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: 'Email', fillColor: Colors.white, filled: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  labelText: 'Password', fillColor: Colors.white, filled: true),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.green,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, rellena todos los campos')),
                  );
                  return;
                }
                try {
                  await Supabase.instance.client.auth.signUp(
                      password: passwordController.text,
                      email: emailController.text);
                  ScaffoldMessenger.of(Get.context!).showSnackBar(
                      const SnackBar(
                          content: Text('Registro completado con éxito')));
                } catch (e) {
                  ScaffoldMessenger.of(Get.context!).showSnackBar(
                      const SnackBar(
                          content: Text('Error al registrar el usuario')));
                }
              },
              child: const Text('Registrarse como usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
