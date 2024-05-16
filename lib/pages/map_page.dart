import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/walking_cubit.dart';
import 'package:pet_clean/widgets/mapa_widget.dart';
import 'package:pet_clean/widgets/walking_switch_widget.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walkingCubit = context.watch<WalkingCubit>();
    return walkingCubit.state
        ? const Mapa()
        : const Column(
            children: [
              Center(
                child: Text('Activa la opción de caminar para ver el mapa'),
              ),
              WalkingSwitch(),
            ],
          );
  }
}
