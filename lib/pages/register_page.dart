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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  Get.snackbar('Error', 'Email y password son requeridos',
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
                try {
                  await Supabase.instance.client.auth.signUp(
                      password: passwordController.text,
                      email: emailController.text);
                  Get.snackbar('Registro correcto', 'Usuario registrado',
                      backgroundColor: Colors.green, colorText: Colors.white);
                } catch (e) {
                  Get.snackbar('Error',
                      'Error con los datos introducidos: ${e.toString()}',
                      backgroundColor: Colors.red, colorText: Colors.white);
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
