import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:pet_clean/models/pet_model.dart';
import 'package:pet_clean/models/user_data_model.dart';
import 'package:pet_clean/models/user_location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MongoDatabase {
  static MongoDatabase? _instance;

  MongoDatabase._();

  factory MongoDatabase() {
    _instance ??= MongoDatabase._();
    return _instance!;
  }

  //int retryAttempts = 5;

  static bool started = false;

  static Db? _db;
  static const int maxRetries = 5;
  //Future<Db> get db async => getConnection();

  Future<Db> get db async {
    if (_db == null) {
      int retries = 0;
      while (retries < maxRetries) {
        try {
          _db = await Db.create(dotenv.env['MONGO_CONNECTION_STRING']!);
          await _db!.open();
          break;
        } catch (e) {
          if (e is MongoDartError) {
            log('Error de MongoDB: $e');
          } else {
            log('Error desconocido: $e');
          }
          await Future.delayed(const Duration(seconds: 2));
          retries++;
        }
      }
      if (retries == maxRetries) {
        log('Failed to connect to MongoDB after $maxRetries attempts');
        throw Exception('Failed to connect to MongoDB');
      }
    }
    return _db!;
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
    }
  }

  // Future<Db> getConnection() async {
  //   if (_db == null || !_db!.isConnected) {
  //     await close();
  //     var retry = 0;
  //     const maxRetries = 5;

  //     while (retry < maxRetries) {
  //       try {
  //         retry++;
  //         var db = await Db.create(dotenv.env['MONGO_CONNECTION_STRING']!);
  //         await db.open();
  //         _db = db;
  //         return _db!;
  //       } on MongoDartError catch (e) {
  //         log('MongoDB connection error: $e');
  //         await Future.delayed(Duration(milliseconds: 100 * retry));
  //       } catch (e) {
  //         log('Unexpected error: $e');
  //         rethrow;
  //       }
  //     }

  //     log('Failed to connect to MongoDB after $maxRetries attempts');
  //     throw Exception('Failed to connect to MongoDB');
  //   }
  //   return _db!;
  // }

  static Future<void> insertMarker(Map<String, dynamic> data) async {
    try {
      var db = await MongoDatabase().db;
      await db.collection('markers').update(
        {'userId': data['userId']}, // Filtro de consulta
        data, // Datos a insertar o actualizar
        upsert: true, // Crea un nuevo documento si no se encuentra ninguno
      );
    } catch (e) {
      if (e is MongoDartError) {
        log('Error de MongoDB: $e');
      } else {
        log('Error desconocido: $e');
      }
    }
  }

  static Future<List<UserLocationModel>> searchOtherUsers(
      double lat, double lon, double range) async {
    try {
      var db = await MongoDatabase().db;
      String? userId = Supabase.instance.client.auth.currentUser?.id;
      List<UserLocationModel> otherUsersFound = [];

      //var minutesToExpire = 5;

      var findParameters = {
        'longlat': {
          '\$near': [lon, lat],
          '\$maxDistance': range / 100000
        },
        'userId': {'\$ne': userId},
        // 'date': {
        //   '\$gte': DateTime.now().subtract(Duration(minutes: minutesToExpire))
        // },
      };

      var query = db.collection('markers').find(findParameters);

      List<Map<String, dynamic>> records = await query.toList();

      for (var record in records) {
        otherUsersFound.add(UserLocationModel(
          userId: record['userId'].toString(),
          latitude: record['latitude'],
          longitude: record['longitude'],
        ));
      }
      return otherUsersFound;
    } catch (e) {
      log('Error retrieving markers: $e');
      return [];
    }
  }

  static Future<void> saveUserData(UserData userData) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var map = userData.toMap();
      await collection.update(
        {'userId': userData.userId},
        map,
        upsert: true,
      );
    } catch (e) {
      log('Error saving user data: $e');
    }
  }

  static Future<UserData> getUserData(String userId) async {
    try {
      log('Getting user data for user: $userId');
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      return UserData.fromMap(result!);
    } catch (e) {
      log('Error getting user data: $e');
      return UserData.empty;
    }
  }

  static Future<void> addPet(String userId, Pet pet) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      var pets = result!['pets'] as List;
      pets.add(pet.toMap());
      await collection.update(query, {
        '\$set': {'pets': pets}
      });
    } catch (e) {
      log('Error añadiendo mascota: $e');
    }
  }

  static Future<void> updatePet(String userId, Pet pet, int petPosition) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      var pets = result!['pets'] as List;
      pets[petPosition] = pet.toMap();
      await collection.update(query, {
        '\$set': {'pets': pets}
      });
    } catch (e) {
      log('Error actualizando mascota: $e');
    }
  }

  static Future<void> deletePet(String userId, int petPosition) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      var pets = result!['pets'] as List;
      pets.removeAt(petPosition);
      await collection.update(query, {
        '\$set': {'pets': pets}
      });
    } catch (e) {
      log('Error eliminando mascota: $e');
    }
  }

  static Future<void> setPetAvatarURL(
      String userId, int petPosition, String avatarURL) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      var pets = result!['pets'] as List;
      pets[petPosition]['avatarURL'] = avatarURL;
      await collection.update(query, {
        '\$set': {'pets': pets}
      });
    } catch (e) {
      log('Error setting pet avatar URL: $e');
    }
  }

  static void markPetBeingWalked(String userId, int index, bool? value) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      var pets = result!['pets'] as List;
      pets[index]['isBeingWalked'] = value;
      await collection.update(query, {
        '\$set': {'pets': pets}
      });
    } catch (e) {
      log('Error marking pet being walked: $e');
    }
  }

  static void switchPetBeingWalked(String userId, int index) async {
    try {
      var db = await MongoDatabase().db;
      var collection = db.collection('users');
      var query = where.eq('userId', userId);
      var result = await collection.findOne(query);
      var pets = result!['pets'] as List;
      pets[index]['isBeingWalked'] = !pets[index]['isBeingWalked'];
      await collection.update(query, {
        '\$set': {'pets': pets}
      });
    } catch (e) {
      log('Error switching pet being walked: $e');
    }
  }
}
