import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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

    return GestureDetector(
      onTap: () {
        walkingCubit.toggleWalking();
      },
      child: Row(
        children: [
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
          !walkingCubit.state
              ? const SizedBox(width: 10)
              : Transform.translate(
                  offset: const Offset(0, -10),
                  child: Lottie.asset(
                    'assets/perrito_marron_andando.json',
                    animate: walkingCubit.state ? true : false,
                    width: 80,
                    height: 800,
                    fit: BoxFit.cover,
                  ),
                ).animate().fade().slideX(duration: 2.seconds),
        ],
      ),
    );
  }
}
