import 'package:bloc/bloc.dart';

class MapStyleCubit extends Cubit<String> {
  MapStyleCubit() : super('josemiguel/cluz800ct005g01qvc40k523n');

  void switchStyle() {
    final style = state == 'josemiguel/cluz800ct005g01qvc40k523n'
        ? 'mapbox/satellite-streets-v12'
        : 'josemiguel/cluz800ct005g01qvc40k523n';
    emit(style);
  }
}
