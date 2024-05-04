import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/models/user_data_model.dart';

class UserDataCubit extends Cubit<UserData> {
  static final UserDataCubit _singleton = UserDataCubit._internal();

  factory UserDataCubit() {
    return _singleton;
  }

  UserDataCubit._internal() : super(UserData.empty);

  void setUserData(UserData userData) => emit(userData);

  void clearUserData() => emit(UserData.empty);

  void updateUserData({
    required String userId,
    required String nombre,
  }) {
    final userData = state.copyWith(
      userId: userId,
      nombre: nombre,
    );
    emit(userData);
  }
}
