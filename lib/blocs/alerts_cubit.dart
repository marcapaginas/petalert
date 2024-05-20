import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/blocs/user_data_cubit.dart';
import 'package:pet_clean/database/redis_database.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/models/user_data_model.dart';
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

  void setAlerts(List<UserLocationModel> foundLocations) async {
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
        final UserData userFoundData =
            await RedisDatabase().getUserData(location.userId);

        String title = '${userFoundData.nombre} está cerca';
        String description =
            'Está paseando a ${_formatPetNames(userFoundData.pets.where((pet) => pet.isBeingWalked).toList())}';

        AlertModel alertforLocation = AlertModel(
          id: location.userId,
          title: title,
          description: description,
          date: DateTime.now(),
          isDiscarded: false,
        );
        currentAlerts.add(alertforLocation);
        if (userDataCubit.state.backgroundNotify) {
          NotificationService.show(title: title, body: description);
        }
      }
    }

    emit(currentAlerts);
  }

  String _formatPetNames(List<Pet> pets) {
    var names = pets.map((pet) => pet.name).toList();
    if (names.length > 1) {
      var last = names.removeLast();
      return '${names.join(', ')} y $last';
    } else if (names.length == 1) {
      return names[0];
    } else {
      return '';
    }
  }
}
