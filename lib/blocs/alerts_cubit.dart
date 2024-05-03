import 'package:bloc/bloc.dart';
import 'package:pet_clean/models/alert_model.dart';
import 'package:pet_clean/models/user_location_model.dart';

class AlertsCubit extends Cubit<List<AlertModel>> {
  AlertsCubit() : super([]);

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

  void setAlerts(List<UserLocationModel> result) {
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
        alerts.add(AlertModel(
          id: userLocation.userId!,
          title: 'Alerta ${userLocation.userId}',
          description: 'Usuario ${userLocation.userId} cerca',
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
