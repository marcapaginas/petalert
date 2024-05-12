import 'dart:convert' as convert;
import 'dart:developer';

import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:redis/redis.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RedisDatabase {
  final conn = RedisConnection();

  Future<Command> connectAndAuth() async {
    final command = await conn.connect(dotenv.get('REDIS_HOST'), 14536);
    await command.send_object(
        ["AUTH", dotenv.get('REDIS_USERNAME'), dotenv.get('REDIS_PASSWORD')]);
    return command;
  }

  Future<void> storeUserData(String userId, UserData userData) async {
    final command = await connectAndAuth();

    await command.set('usuario:$userId', userData.toJson());
  }

  Future<UserData> getUserData(String userId) async {
    final command = await connectAndAuth();
    final String string = await command.get('usuario:$userId');
    Map<String, dynamic> mapa = convert.jsonDecode(string);
    log(mapa.toString());
    if (mapa.isNotEmpty) {
      log(UserData.fromJson(mapa).toString());
      return UserData.fromJson(mapa);
    }
    return UserData.empty;
  }

  Future<void> storeUserLocation(UserLocationModel userLocation) async {
    final command = await connectAndAuth();
    await command.send_object([
      "GEOADD",
      "userLocations",
      userLocation.longitude.toString(),
      userLocation.latitude.toString(),
      userLocation.userId
    ]);
  }

  Future<List<String>> getUserLocationsByDistance(
      double longitude, double latitude, double radius, String unit) async {
    final command = await connectAndAuth();
    final response = await command.send_object([
      "GEORADIUS",
      "userLocations",
      longitude.toString(),
      latitude.toString(),
      radius.toString(),
      unit
    ]);
    return response;
  }
}
