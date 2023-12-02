import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'food_calories.db';
  static const String tableFoodCalories = 'food_calories';
  static const String tableMealPlans = 'meal_plans';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFoodCalories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food TEXT,
        calories INTEGER
      )
    ''');

    List<Map<String, dynamic>> presetFoods = [
      {'food': 'Apple', 'calories': 52},
      {'food': 'Banana', 'calories': 89},
      {'food': 'Chicken Breast', 'calories': 165},
      {'food': 'Broccoli', 'calories': 55},
      {'food': 'Salmon', 'calories': 200},
      {'food': 'Spinach', 'calories': 23},
      {'food': 'Rice', 'calories': 130},
      {'food': 'Avocado', 'calories': 160},
      {'food': 'Egg', 'calories': 70},
      {'food': 'Yogurt', 'calories': 120},
      {'food': 'Carrot', 'calories': 41},
      {'food': 'Potato', 'calories': 161},
      {'food': 'Orange', 'calories': 62},
      {'food': 'Peanut Butter', 'calories': 94},
      {'food': 'Almonds', 'calories': 7},
      {'food': 'Oatmeal', 'calories': 68},
      {'food': 'Grapes', 'calories': 67},
      {'food': 'Cheese', 'calories': 402},
      {'food': 'Tomato', 'calories': 18},
      {'food': 'Turkey', 'calories': 189},
    ];

    for (var food in presetFoods) {
      await db.insert(tableFoodCalories, food);
    }

    await db.execute('''
      CREATE TABLE $tableMealPlans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        targetCalories INTEGER,
        foodItems TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $tableMealPlans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          targetCalories INTEGER,
          foodItems TEXT
        )
      ''');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodCalories() async {
    final db = await database;
    return await db.query(tableFoodCalories);
  }

  Future<void> addFoodCaloriePair(String food, int calories) async {
    final db = await database;
    await db.insert(
      tableFoodCalories,
      {'food': food, 'calories': calories},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFoodCaloriePair(int id, String food, int calories) async {
    final db = await database;
    await db.update(
      tableFoodCalories,
      {'food': food, 'calories': calories},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFoodPair(int id) async {
    final db = await database;
    await db.delete(
      tableFoodCalories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addMealPlan(DateTime date, int targetCalories, String foodItemsJson) async {
    final db = await database;
    await db.insert(
      tableMealPlans,
      {
        'date': date.toIso8601String(),
        'targetCalories': targetCalories,
        'foodItems': foodItemsJson
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMealPlans() async {
    final db = await database;
    return await db.query(tableMealPlans);
  }

  Future<void> deleteMealPlan(int id) async {
    final db = await database;
    await db.delete(
      tableMealPlans,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMealPlan(int id, DateTime date, int targetCalories, String foodItemsJson) async {
    final db = await database;
    await db.update(
      tableMealPlans,
      {
        'date': date.toIso8601String(),
        'targetCalories': targetCalories,
        'foodItems': foodItemsJson
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> debugPrintDatabaseContents() async {
    final db = await database;
    final resultFoodCalories = await db.query(tableFoodCalories);
    final resultMealPlans = await db.query(tableMealPlans);
    print('Food Calorie Table: $resultFoodCalories');
    print('Meal Plans Table: $resultMealPlans');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(tableFoodCalories);
    await db.delete(tableMealPlans);
  }

  void resetAndInitializeDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearDatabase();
    await dbHelper.initDatabase();
    print('Database reset and initialized.');
  }

}
