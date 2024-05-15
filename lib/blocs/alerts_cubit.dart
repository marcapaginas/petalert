import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:pet_clean/services/notification_service.dart';

class AlertsCubit extends Cubit<List<AlertModel>> {
  final UserDataCubit userDataCubit;
  static AlertsCubit? _singleton;

  factory AlertsCubit(UserDataCubit userDataCubit) {
    _singleton ??= AlertsCubit._internal(userDataCubit);
    return _singleton!;
  }

  AlertsCubit._internal(this.userDataCubit) : super([]);

  void addAlert(AlertModel alert) {
    emit(<AlertModel>[...state, alert]);
  }

  void removeAlert(AlertModel alert) {
    emit(List<AlertModel>.from(state)..remove(alert));
  }

  void updateAlert(AlertModel alert) {
    final index = state.indexWhere((element) => element.id == alert.id);
    state[index] = alert;
    emit(List<AlertModel>.from(state));
  }

  void markAsDiscarded(userId) {
    final index = state.indexWhere((element) => element.id == userId);
    state[index].isDiscarded = true;
    emit(List<AlertModel>.from(state));
  }

  get notDiscardedAlerts => state.where((alert) => !alert.isDiscarded).toList();

  void clearAlerts() {
    emit(List<AlertModel>.empty());
  }

  void setAlerts(List<UserLocationModel> foundLocations) {
    final currentAlerts = List<AlertModel>.from(state);
    final discardedAlerts =
        currentAlerts.where((alert) => alert.isDiscarded).toList();

    for (var alert in discardedAlerts) {
      if (!foundLocations.any((location) => location.userId == alert.id)) {
        currentAlerts.remove(alert);
      }
    }

    for (var location in foundLocations) {
      if (currentAlerts.any((alert) => alert.id == location.userId)) {
        continue;
      } else {
        AlertModel alertforLocation = AlertModel(
          id: location.userId,
          title: 'Alerta',
          description: 'alerta usuario ${location.userId}',
          date: DateTime.now(),
          isDiscarded: false,
        );
        currentAlerts.add(alertforLocation);
        if (userDataCubit.state.backgroundNotify) {
          NotificationService.show(
              title: 'Alerta',
              body:
                  '${userDataCubit.state.nombre.isNotEmpty ? userDataCubit.state.nombre : 'Alguien'} cerca, paseando a ${userDataCubit.state.pets.where((pet) => pet.isBeingWalked).toList().length} ${userDataCubit.state.pets.where((pet) => pet.isBeingWalked).toList().length == 1 ? 'mascota' : 'mascotas'}');
        }
      }
    }

    emit(currentAlerts);
  }
}
