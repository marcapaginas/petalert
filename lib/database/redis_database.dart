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
    await command.send_object(["AUTH", dotenv.get('REDIS_PASSWORD')]);
    return command;
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
      await conn.close();
    }
  }

  void processHashMap(Map<String, dynamic> hashMap, List<dynamic> hmsetData) {
    hashMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        // Si el valor es un HashMap, se llama recursivamente
        processHashMap(value, hmsetData);
      } else {
        // Si el valor no es un HashMap, se añade a la lista
        hmsetData
          ..add(key)
          ..add(value.toString());
      }
    });
  }

  Future<void> setUser(UserData user) async {
    final command = await connectAndAuth();

    // Convertir el objeto de usuario a un mapa
    Map<String, dynamic> userMap = user.toMap();

    // Preparar los datos para HMSET
    List<dynamic> hmsetData = [];
    processHashMap(userMap, hmsetData);
    // userMap.forEach((key, value) {
    //   hmsetData
    //     ..add(key)
    //     ..add(value.toString());
    // });

    // Guardar el usuario en Redis como un hashmap
    await command.send_object(['HMSET', 'user:${user.userId}', ...hmsetData]);
  }

  Future<UserData> getUserData(String userId) async {
    UserData userData = UserData.empty;
    RedisConnection? redisConnection;
    userData = UserData(
      userId: userId,
      nombre: 'Usuario',
      pets: [],
    );

    try {
      final command = await connectAndAuth();
      redisConnection = command.get_connection();
      final String string = await command.get('usuario:$userId');
      final Map<String, dynamic> mapa = convert.jsonDecode(string);
      userData = UserData.fromJson(mapa);
    } catch (e) {
      log('Error al obtener el usuario: $e');
    } finally {
      if (redisConnection != null) {
        await redisConnection.close();
      }
    }

    return userData;
  }

  Future<void> storeUserLocation(UserLocationModel userLocation) async {
    RedisConnection? redisConnection;

    try {
      final command = await connectAndAuth();
      redisConnection = command.get_connection();
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
          userLocation.lastUpdate,
        ]);
      }
    } catch (e) {
      log('Error al guardar la ubicación del usuario: $e');
    } finally {
      if (redisConnection != null) {
        await redisConnection.close();
      }
    }
  }

  Future<List<UserLocationModel>> getActiveUserLocations(
      double longitude, double latitude, double radius, int minutes) async {
    final command = await connectAndAuth();
    final currentTime = DateTime.now();
    String currentUserId = Supabase.instance.client.auth.currentUser!.id;

    // Obtener usuarios cercanos junto con sus posiciones
    final nearbyUsers = await command.send_object([
      "GEORADIUS",
      "userLocations",
      longitude.toString(),
      latitude.toString(),
      radius.toString(),
      "m",
      "WITHCOORD"
    ]);

    if (nearbyUsers.isEmpty) {
      return [];
    }

    // Obtener IDs de los usuarios cercanos
    final nearbyUserIds = nearbyUsers.map((user) => user[0]).toList();

    // Obtener los tiempos de actualización de los usuarios cercanos
    final updates = await command
        .send_object(["HMGET", "userLocationUpdates", ...nearbyUserIds]);

    // Filtrar usuarios activos y crear la lista de ubicaciones
    final activeLocations = <UserLocationModel>[];
    for (var i = 0; i < nearbyUsers.length; i++) {
      final List<dynamic> item = nearbyUsers[i];
      final String userId = item[0];
      final List<dynamic> coordinates = item[1];

      final lastUpdate = int.tryParse(updates[i]) ?? 0;
      final lastUpdateDate = DateTime.fromMillisecondsSinceEpoch(lastUpdate);

      if (userId != currentUserId) {
        int diff = currentTime.difference(lastUpdateDate).inMinutes;

        // tomamos en cuenta solo las ubicaciones actualizadas en los últimos minutos
        if (diff <= minutes) {
          activeLocations.add(UserLocationModel(
            userId: userId,
            longitude: double.parse(coordinates[0]),
            latitude: double.parse(coordinates[1]),
          ));
        }
      }
    }

    return activeLocations;
  }

  Future<List<UserLocationModel>> getUserLocationsByDistance(
      double long, double lat, double radius) async {
    List<UserLocationModel> result = [];
    if (Supabase.instance.client.auth.currentUser == null) {
      return result;
    }
    String currentUserId = Supabase.instance.client.auth.currentUser!.id;
    RedisConnection? redisConnection;

    try {
      final command = await connectAndAuth();
      redisConnection = command.get_connection();
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
        throw Exception("Error getting user locations: ${response.message}");
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
      if (redisConnection != null) {
        await redisConnection.close();
      }
    }

    return result;
  }
}
