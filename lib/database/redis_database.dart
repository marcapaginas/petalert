import 'dart:convert' as convert;
import 'dart:developer';

import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:redis/redis.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RedisDatabase {
  final conn = RedisConnection();

  Future<Command> connectAndAuth() async {
    Command command =
        await conn.connect(dotenv.get('REDIS_HOST_PETALERT'), 6379);
    await command.send_object(["AUTH", 'petalert']);
    return command;
  }

  // close
  Future<void> close() async {
    await conn.close();
  }

  //check connection
  Future<void> checkConnection() async {
    try {
      final command = await connectAndAuth();
      final response = await command.set('ping', 'pong');
      log('Redis connection: $response');
    } catch (e) {
      log('Error al conectar con Redis: $e');
    }
  }

  Future<void> storeUserData(UserData userData) async {
    try {
      final command = await connectAndAuth();
      await command.set('usuario:${userData.userId}', userData.toJson());
    } catch (e) {
      log('Error al guardar el usuario: $e');
    } finally {
      await close();
    }
  }

  Future<UserData> getUserData(String userId) async {
    UserData userData = UserData.empty;

    try {
      final command = await connectAndAuth();
      final String string = await command.get('usuario:$userId');
      final Map<String, dynamic> mapa = convert.jsonDecode(string);
      userData = UserData.fromJson(mapa);
    } catch (e) {
      userData = UserData(
        userId: userId,
        nombre: 'Usuario',
        pets: [],
      );
      await storeUserData(userData);
    } finally {
      await close();
    }

    return userData;
  }

  Future<void> storeUserLocation(UserLocationModel userLocation) async {
    try {
      final command = await connectAndAuth();
      await command.send_object([
        "GEOADD",
        "userLocations",
        userLocation.longitude.toString(),
        userLocation.latitude.toString(),
        userLocation.userId,
      ]);

      if (userLocation.lastUpdate != null) {
        await command.send_object([
          "HSET",
          "userLocationUpdates",
          userLocation.userId,
          userLocation.lastUpdate!.millisecondsSinceEpoch.toString(),
        ]);
      }
    } catch (e) {
      log('Error al guardar la ubicación del usuario: $e');
    } finally {
      await close();
    }
  }

  // get al user locations
  Future<List<UserLocationModel>> getUserLocations() async {
    final command = await connectAndAuth();
    final members =
        await command.send_object(["ZRANGE", "userLocations", "0", "-1"]);
    final locations = <UserLocationModel>[];

    for (var userId in members) {
      final coordinates =
          await command.send_object(["GEOPOS", "userLocations", userId]);
      if (coordinates.isNotEmpty) {
        locations.add(UserLocationModel(
          userId: userId,
          longitude: double.parse(coordinates[0][0]),
          latitude: double.parse(coordinates[0][1]),
        ));
      }
    }
    log(locations.toString());

    return locations;
  }

  Future<List<UserLocationModel>> getActiveUserLocations(
      double longitude, double latitude, double radius, int minutes) async {
    final command = await connectAndAuth();
    final fiveMinutesAgo = DateTime.now()
        .subtract(Duration(minutes: minutes))
        .millisecondsSinceEpoch;
    final nearbyUserIds = await command.send_object([
      "GEORADIUS",
      "userLocations",
      longitude.toString(),
      latitude.toString(),
      radius.toString(),
      "m"
    ]);
    final updates = await command
        .send_object(["HMGET", "userLocationUpdates", ...nearbyUserIds]);

    final activeUserIds = <String>[];
    for (var i = 0; i < nearbyUserIds.length; i++) {
      final userId = nearbyUserIds[i];
      final lastUpdate = int.parse(updates[i]);
      if (lastUpdate >= fiveMinutesAgo) {
        activeUserIds.add(userId);
      }
    }

    final locations = <UserLocationModel>[];
    for (var userId in activeUserIds) {
      final coordinates =
          await command.send_object(["GEOPOS", "userLocations", userId]);
      if (coordinates.isNotEmpty) {
        locations.add(UserLocationModel(
          userId: userId,
          longitude: double.parse(coordinates[0][0]),
          latitude: double.parse(coordinates[0][1]),
        ));
      }
    }

    return locations;
  }

  Future<List<UserLocationModel>> getUserLocationsByDistance(
      double long, double lat, double radius) async {
    List<UserLocationModel> result = [];
    String currentUserId = Supabase.instance.client.auth.currentUser!.id;

    try {
      final command = await connectAndAuth();
      final response = await command.send_object([
        "GEORADIUS",
        "userLocations",
        long.toString(),
        lat.toString(),
        radius.toString(),
        'm',
        "WITHCOORD", // Include coordinates in response
      ]);

      if (response.runtimeType == RedisError) {
        throw Exception("Error fetching user locations: ${response.message}");
      }

      for (var i = 0; i < response.length; i++) {
        final List<dynamic> item = response[i];
        final List<dynamic> coordinates = item[1];
        final String userId = item[0];

        if (userId != currentUserId) {
          result.add(UserLocationModel(
            userId: userId,
            latitude: double.parse(coordinates[1]),
            longitude: double.parse(coordinates[0]),
          ));
        }
      }
    } catch (e) {
      log('Error al obtener las ubicaciones de los usuarios: $e');
    } finally {
      await close();
    }

    return result;
  }
}
