import 'package:bloc/bloc.dart';

class UsernameCubit extends Cubit<String> {
  UsernameCubit() : super('no_username');

  void setUsername(String username) => emit(username);
}
