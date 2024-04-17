import 'package:flutter/material.dart';
import 'package:pet_clean/widgets/custom_switch.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Geolocalización:'),
            CustomSwitch(),
          ],
        ),
      ),
    );
  }
}
