import 'package:pet_clean/blocs/user_data_cubit.dart';

class UserDataCubitSingleton {
  static final UserDataCubitSingleton _singleton =
      UserDataCubitSingleton._internal();

  factory UserDataCubitSingleton() {
    return _singleton;
  }

  UserDataCubitSingleton._internal();

  final UserDataCubit userDataCubit = UserDataCubit();
}
