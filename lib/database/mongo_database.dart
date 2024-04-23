import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static Db? db;

  // singleton pattern
  MongoDatabase._privateConstructor();
  static final MongoDatabase instance = MongoDatabase._privateConstructor();

  static connect() async {
    await dotenv.load();

    db = await Db.create(dotenv.env['MONGO_CONNECTION_STRING']!);
    await db!.open();

    await db!.createCollection('markers');
  }

  static close() {
    db!.close();
  }

  static insert(Map<String, dynamic> data) async {
    try {
      if (db == null) {
        await connect();
      }
      await db!.collection('markers').update(
        {'userId': data['userId']}, // Filtro de consulta
        data, // Datos a insertar o actualizar
        upsert: true, // Crea un nuevo documento si no se encuentra ninguno
      );
      log('Data inserted: $data');
    } catch (e) {
      log('Error inserting data: $e');
    }
  }
}
