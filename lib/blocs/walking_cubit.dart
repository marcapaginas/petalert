import 'package:flutter_bloc/flutter_bloc.dart';

class WalkingCubit extends Cubit<bool> {
  WalkingCubit() : super((false));

  void toggleWalking() => emit(!state);
}
