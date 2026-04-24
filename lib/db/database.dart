import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/coffee_shop.dart';

// This class handles all communication with the local database on the phone.
// Think of it as the "filing cabinet manager" — it knows how to store and retrieve shops.
class DatabaseHelper {
  static Database? _database;

  // Singleton: ensures only one database connection exists at a time
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'coffee_spots.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Creates the "shops" table the first time the app runs
        return db.execute('''
          CREATE TABLE shops(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            drink TEXT NOT NULL,
            recommendedBy TEXT NOT NULL,
            address TEXT NOT NULL,
            photoPath TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Save a new shop
  static Future<void> insertShop(CoffeeShop shop) async {
    final db = await database;
    await db.insert('shops', shop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all shops, newest first
  static Future<List<CoffeeShop>> getAllShops() async {
    final db = await database;
    final maps = await db.query('shops', orderBy: 'createdAt DESC');
    return maps.map((map) => CoffeeShop.fromMap(map)).toList();
  }

  // Update an existing shop (used when adding a photo)
  static Future<void> updateShop(CoffeeShop shop) async {
    final db = await database;
    await db.update('shops', shop.toMap(), where: 'id = ?', whereArgs: [shop.id]);
  }

  // Delete a shop permanently
  static Future<void> deleteShop(String id) async {
    final db = await database;
    await db.delete('shops', where: 'id = ?', whereArgs: [id]);
  }
}
