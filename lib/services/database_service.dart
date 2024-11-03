import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  
  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    // Get the default database path
    String path = join(await getDatabasesPath(), 'ecommerce.db');
    
    // Open/create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Create category table with index on name
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_category_name ON categories(name)');

    // Create products table with indexes on name and category_id
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category_id INTEGER NOT NULL,
        image_url TEXT,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_product_name ON products(name)');
    await db.execute('CREATE INDEX idx_product_category ON products(category_id)');

    // Create reviews table with index on product_id
    await db.execute('''
      CREATE TABLE reviews(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        rating INTEGER NOT NULL CHECK(rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_review_product ON reviews(product_id)');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}