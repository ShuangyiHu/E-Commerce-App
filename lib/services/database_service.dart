import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/review.dart';

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
    String path = join(await getDatabasesPath(), 'ecommerce.db');
    
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

  // Add a new category
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  // Retrieve all categories
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  // Search categories with filtering and sorting
  Future<List<Category>> searchCategories({
    String? searchText,
    String? searchField = 'name',
    String? orderBy = 'name',
    bool descending = false,
  }) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;
    String orderByClause = orderBy != null 
        ? '$orderBy ${descending ? 'DESC' : 'ASC'}'
        : 'name ASC';

    if (searchText != null && searchText.isNotEmpty && searchField != null) {
      whereClause = '$searchField LIKE ?';
      whereArgs = ['%$searchText%'];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderByClause,
    );

    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // Update a category
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete a category
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add a new product
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  // Retrieve all products
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Update a product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete a product
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Add a new review
  Future<int> insertReview(Review review) async {
    final db = await database;
    return await db.insert('reviews', review.toMap());
  }

  // Retrieve all reviews
  Future<List<Review>> getReviews() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reviews');
    return List.generate(maps.length, (i) {
      return Review.fromMap(maps[i]);
    });
  }

  // Update a review
  Future<int> updateReview(Review review) async {
    final db = await database;
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  // Delete a review
  Future<int> deleteReview(int id) async {
    final db = await database;
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}