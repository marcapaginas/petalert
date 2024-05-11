import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/database/mongo_database.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/models/user_location_model.dart';

class AlertsCubit extends Cubit<List<AlertModel>> {
  static final AlertsCubit _singleton = AlertsCubit._internal();

  factory AlertsCubit() {
    return _singleton;
  }

  AlertsCubit._internal() : super([]);

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

  void setAlerts(List<UserLocationModel> result) async {
    if (result.isEmpty) {
      emit(state);
      return;
    }

    final currentAlerts = List<AlertModel>.from(state);
    final alerts = <AlertModel>[];

    for (final userLocation in result) {
      final existingAlert = currentAlerts.firstWhere(
        (alert) => alert.id == userLocation.userId,
        orElse: () => AlertModel(
            id: '',
            title: '',
            description: '',
            date: DateTime.now(),
            isDiscarded: false),
      );

      if (existingAlert.id.isNotEmpty) {
        alerts.add(existingAlert);
      } else {
        UserData usuario;
        try {
          usuario = await MongoDatabase.getUserData(userLocation.userId!);
        } catch (e) {
          log('Error getting user data: $e');
          return;
        }
        // get user data using userId

        // count pets that are being walked
        int petsBeingWalked =
            usuario.pets.where((pet) => pet.isBeingWalked).toList().length;
        alerts.add(AlertModel(
          id: userLocation.userId!,
          title: 'Alerta',
          description:
              '${usuario.nombre.isNotEmpty ? usuario.nombre : 'Alguien'} está cerca y está paseando a $petsBeingWalked mascotas',
          date: DateTime.now(),
          isDiscarded: false,
        ));
      }
    }

    for (final alert in currentAlerts) {
      if (!alerts.contains(alert) && !alert.isDiscarded) {
        alerts.add(alert);
      }
    }

    emit(alerts);
  }
}
