import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_clean/blocs/walking_cubit.dart';
import 'package:pet_clean/widgets/mapa_widget.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walkingCubit = context.watch<WalkingCubit>();
    return walkingCubit.state
        ? const Mapa()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/siluetas_perros.json', width: 300),
              const SizedBox(height: 20),
              const Center(
                child: Text('Debes iniciar el paseo para ver el mapa.'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => walkingCubit.toggleWalking(),
                  child: const Text(
                    'Iniciar paseo',
                    style: TextStyle(color: Colors.green),
                  ))
            ],
          );
  }
}
