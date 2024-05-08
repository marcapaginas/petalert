import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_clean/models/pet_model.dart';
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
    required List<Pet> pets,
  }) {
    final userData = state.copyWith(
      userId: userId,
      nombre: nombre,
      pets: pets,
    );
    emit(userData);
  }

  void addPet(Pet pet) {
    final userData = state.copyWith(
      pets: [...state.pets, pet],
    );

    emit(userData);
  }

  void updatePet(int petIndex, Pet pet) {
    final userData = state.copyWith(
      pets: List<Pet>.from(state.pets)..[petIndex] = pet,
    );
    emit(userData);
  }

  void removePet(int petIndex) {
    final userData = state.copyWith(
      pets: List<Pet>.from(state.pets)..removeAt(petIndex),
    );
    emit(userData);
  }

  void setPetAvatar(int index, String avatarUrl) {
    final userData = state.copyWith(
      pets: List<Pet>.from(state.pets)
        ..[index] = state.pets[index].copyWith(avatarURL: avatarUrl),
    );
    emit(userData);
  }

  void unsetPetAvatar(int index) {
    final userData = state.copyWith(
      pets: List<Pet>.from(state.pets)
        ..[index] = state.pets[index].copyWith(avatarURL: ''),
    );
    emit(userData);
  }

  void markPetBeingWalked(int index) {
    final userData = state.copyWith(
      pets: List<Pet>.from(state.pets)
        ..[index] = state.pets[index].copyWith(isBeingWalked: true),
    );
    emit(userData);
  }

  void markPetNotBeingWalked(int index) {
    final userData = state.copyWith(
      pets: List<Pet>.from(state.pets)
        ..[index] = state.pets[index].copyWith(isBeingWalked: false),
    );
    emit(userData);
  }
}
