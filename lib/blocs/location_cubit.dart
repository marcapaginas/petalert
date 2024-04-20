import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';

class LocationCubit extends Cubit<LatLng> {
  LocationCubit() : super(const LatLng(0, 0));

  void setLocation(LatLng location) => emit(location);
}
