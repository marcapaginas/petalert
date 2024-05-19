import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/blocs/walking_cubit.dart';

class WalkingSwitch extends StatefulWidget {
  const WalkingSwitch({
    super.key,
  });

  @override
  State<WalkingSwitch> createState() => _WalkingSwitchState();
}

class _WalkingSwitchState extends State<WalkingSwitch>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walkingCubit = context.watch<WalkingCubit>();
    final userDataCubit = context.read<UserDataCubit>();

    return GestureDetector(
      onTap: () {
        if (userDataCubit.state.walkingPets.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecciona al menos una mascota para pasear'),
            ),
          );
        } else {
          walkingCubit.toggleWalking();
        }
      },
      child: Row(
        children: [
          !walkingCubit.state
              ? const SizedBox(width: 10)
              : Animate(
                  effects: [
                    const FadeEffect(duration: Duration(seconds: 2)),
                    SlideEffect(
                      begin: const Offset(-1, 0),
                      duration: 2.seconds,
                    ),
                  ],
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: Lottie.asset(
                      'assets/perrito_marron_andando.json',
                      animate: walkingCubit.state ? true : false,
                      width: 80,
                      height: 800,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          Container(
            alignment: Alignment.center,
            width: 125,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: walkingCubit.state ? Colors.red : Colors.green,
            ),
            child: Text(
              walkingCubit.state ? 'Parar Paseo' : 'Empezar Paseo',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
