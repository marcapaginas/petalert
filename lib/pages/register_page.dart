import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // final response = await Supabase.auth.signUp(
                //   email: emailController.text,
                //   password: passwordController.text,
                // );
                final response = await Supabase.instance.client.auth.signUp(
                    password: passwordController.text,
                    email: emailController.text);

                // if (response.error == null) {
                //   // Registration successful
                //   print('User registered successfully');
                // } else {
                //   // Handle registration error
                //   print('Registration error: ${response.error!.message}');
                // }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
