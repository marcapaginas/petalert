import 'package:bloc/bloc.dart';
import 'package:pet_clean/models/alert_model.dart';

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

  void markAsNotified(userId) {
    final index = state.indexWhere((element) => element.userId == userId);
    state[index].isNotified = true;
    emit(List<AlertModel>.from(state));
  }

  void clearAlerts() {
    emit(List<AlertModel>.empty());
  }
}
