import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:pet_clean/blocs/map_options_cubit.dart';

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

    _controller = AnimationController(vsync: this)
      ..value = 0.5
      ..addListener(() {
        setState(() {
          // Rebuild the widget at each frame to update the "progress" label.
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapOptionsCubit = context.watch<MapOptionsCubit>();

    return InkWell(
      onTap: () {
        mapOptionsCubit.switchWalking();
      },
      splashColor: Colors.green,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ]),
        margin: const EdgeInsets.all(0),
        child: Lottie.asset(
          'assets/perrito_marron_andando.json',
          animate: mapOptionsCubit.state.walking ? true : false,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  _stopWalkingAnimation() {
    //_controller.forward();
  }
}
