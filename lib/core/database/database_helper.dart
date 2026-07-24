import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/admin/data/models/voucher_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/admin/data/models/banner_model.dart';
import '../../features/product/data/models/topping_model.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('coffeeshop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      return await openDatabase(
        inMemoryDatabasePath,
        version: 10,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 10,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS transactions (
  id $textType PRIMARY KEY,
  date $textType,
  subtotal $realType,
  tax $realType,
  discount $realType,
  total $realType,
  paymentAmount $realType,
  change $realType,
  items TEXT
)
''');
    }
    if (oldVersion < 3) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS vouchers (
  code TEXT PRIMARY KEY,
  discountType TEXT NOT NULL,
  discountValue REAL NOT NULL,
  minPurchase REAL NOT NULL,
  isActive INTEGER NOT NULL
)
''');
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN items TEXT');
      } catch (_) {}
    }
    if (oldVersion < 5) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL
)
''');
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN userId TEXT');
      } catch (_) {}
    }
    if (oldVersion < 7) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS banners (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  imageUrl TEXT NOT NULL,
  isActive INTEGER NOT NULL
)
''');
    }

    if (oldVersion < 8) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS favorites (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  productId TEXT NOT NULL
)
''');
      try {
        await db.execute("ALTER TABLE transactions ADD COLUMN status TEXT DEFAULT 'completed'");
      } catch (_) {}
    }

    if (oldVersion < 9) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS toppings (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  category TEXT NOT NULL
)
''');
      for (final t in defaultSeedToppings) {
        await db.insert('toppings', t.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    if (oldVersion < 10) {
      try {
        await db.execute("ALTER TABLE users ADD COLUMN points INTEGER DEFAULT 0");
      } catch (_) {}
    }

    // Seed default admin account
    await db.execute('''
INSERT OR IGNORE INTO users (id, name, email, password, role)
VALUES ('admin-default', 'Administrator', 'admin@gmail.com', 'admin', 'admin')
''');
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE products (
  id $idType,
  name $textType,
  description $textType,
  category $textType,
  price $realType,
  stock $integerType,
  imageUrl $textType
)
''');

    await db.execute('''
CREATE TABLE toppings (
  id $idType,
  name $textType,
  price $realType,
  category $textType
)
''');
    for (final t in defaultSeedToppings) {
      await db.insert('toppings', t.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await db.execute('''
CREATE TABLE users (
  id $idType,
  name $textType,
  email $textType,
  password $textType,
  role $textType,
  points INTEGER DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE transactions (
  id $textType PRIMARY KEY,
  date $textType,
  subtotal $realType,
  tax $realType,
  discount $realType,
  total $realType,
  paymentAmount $realType,
  change $realType,
  items TEXT,
  userId TEXT,
  status TEXT
)
''');

    await db.execute('''
CREATE TABLE favorites (
  id $textType PRIMARY KEY,
  userId $textType,
  productId $textType
)
''');

    await db.execute('''
CREATE TABLE vouchers (
  code $textType PRIMARY KEY,
  discountType $textType,
  discountValue $realType,
  minPurchase $realType,
  isActive $integerType
)
''');

    await db.execute('''
CREATE TABLE banners (
  id $idType,
  title $textType,
  subtitle $textType,
  imageUrl $textType,
  isActive $integerType
)
''');

    // Seed default admin
    await db.insert('users', {
      'id': 'admin-default',
      'name': 'Administrator',
      'email': 'admin@gmail.com',
      'password': 'admin',
      'role': 'admin',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Seeding Initial Data for Coffee Shop
    final initialProducts = [
      Product(
        id: 'CFF-001',
        name: 'Caramel Macchiato',
        description: 'Perpaduan sempurna antara espresso tajam, susu creamy, dan sirup karamel manis yang memanjakan lidah.',
        category: 'Coffee',
        price: 35000,
        stock: 50,
        imageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?q=80&w=600&auto=format&fit=crop',
      ),
      Product(
        id: 'CFF-002',
        name: 'Matcha Latte',
        description: 'Teh hijau matcha Jepang otentik dengan susu segar manis. Menenangkan dan penuh antioksidan.',
        category: 'Non-Coffee',
        price: 32000,
        stock: 40,
        imageUrl: 'https://images.unsplash.com/photo-1536514072410-5019a3c69182?q=80&w=600&auto=format&fit=crop',
      ),
      Product(
        id: 'CFF-003',
        name: 'Iced Americano',
        description: 'Klasik, murni, dan menyegarkan. Espresso khas house blend kami yang disajikan dengan es batu.',
        category: 'Coffee',
        price: 25000,
        stock: 100,
        imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=600&auto=format&fit=crop',
      ),
      Product(
        id: 'CFF-004',
        name: 'Mocha Frappuccino',
        description: 'Blended ice coffee dengan saus cokelat tebal dan whipped cream di atasnya. Surganya para pecinta cokelat.',
        category: 'Frappe',
        price: 40000,
        stock: 30,
        imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?q=80&w=600&auto=format&fit=crop',
      ),
    ];

    for (var product in initialProducts) {
      await db.insert('products', product.toMap());
    }
  }

  // --- CRUD Operations for Products ---

  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return product;
  }

  Future<Product?> readProduct(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'products',
      columns: ['id', 'name', 'description', 'category', 'price', 'stock', 'imageUrl'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Product>> readAllProducts() async {
    try {
      final db = await instance.database;
      const orderBy = 'name ASC';
      final result = await db.query('products', orderBy: orderBy);
      if (result.isNotEmpty) {
        return result.map((json) => Product.fromMap(json)).toList();
      }
    } catch (e) {
      // Memory fallback for web
    }
    return [
      Product(
        id: 'CFF-001',
        name: 'Caramel Macchiato',
        description: 'Perpaduan sempurna antara espresso tajam, susu creamy, dan sirup karamel manis yang memanjakan lidah.',
        category: 'Coffee',
        price: 35000,
        stock: 50,
        imageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?q=80&w=600&auto=format&fit=crop',
      ),
      Product(
        id: 'CFF-002',
        name: 'Matcha Latte',
        description: 'Teh hijau matcha Jepang otentik dengan susu segar manis. Menenangkan dan penuh antioksidan.',
        category: 'Non-Coffee',
        price: 32000,
        stock: 40,
        imageUrl: 'https://images.unsplash.com/photo-1536514072410-5019a3c69182?q=80&w=600&auto=format&fit=crop',
      ),
      Product(
        id: 'CFF-003',
        name: 'Iced Americano',
        description: 'Klasik, murni, dan menyegarkan. Espresso khas house blend kami yang disajikan dengan es batu.',
        category: 'Coffee',
        price: 25000,
        stock: 100,
        imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=600&auto=format&fit=crop',
      ),
      Product(
        id: 'CFF-004',
        name: 'Mocha Frappuccino',
        description: 'Blended ice coffee dengan saus cokelat tebal dan whipped cream di atasnya. Surganya para pecinta cokelat.',
        category: 'Frappe',
        price: 40000,
        stock: 30,
        imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?q=80&w=600&auto=format&fit=crop',
      ),
    ];
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD Operations for Transactions ---

  Future<TransactionRecord> createTransaction(TransactionRecord transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return transaction;
  }

  Future<List<TransactionRecord>> readAllTransactions() async {
    final db = await instance.database;
    final orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);
    return result.map((json) => TransactionRecord.fromMap(json)).toList();
  }

  Future<List<TransactionRecord>> readTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final orderBy = 'date DESC';
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: orderBy,
    );
    return result.map((json) => TransactionRecord.fromMap(json)).toList();
  }

  Future<List<TransactionRecord>> readTransactionsByUser(String userId) async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('transactions', where: 'userId = ?', whereArgs: [userId], orderBy: orderBy);
    return result.map((json) => TransactionRecord.fromMap(json)).toList();
  }

  // --- CRUD Operations for Vouchers ---
  Future<void> createVoucher(Map<String, dynamic> voucher) async {
    final db = await instance.database;
    await db.insert('vouchers', voucher, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> readAllVouchers() async {
    final db = await instance.database;
    return await db.query('vouchers');
  }

  Future<VoucherModel?> getVoucherByCode(String code) async {
    final db = await instance.database;
    final maps = await db.query(
      'vouchers',
      where: 'code = ?',
      whereArgs: [code.toUpperCase()],
    );

    if (maps.isNotEmpty) {
      return VoucherModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> toggleFavorite(String userId, String productId) async {
    final db = await instance.database;
    final existing = await db.query('favorites', where: 'userId = ? AND productId = ?', whereArgs: [userId, productId]);
    if (existing.isEmpty) {
      await db.insert('favorites', {
        'id': '${userId}_$productId',
        'userId': userId,
        'productId': productId
      });
    } else {
      await db.delete('favorites', where: 'userId = ? AND productId = ?', whereArgs: [userId, productId]);
    }
  }

  Future<List<String>> getUserFavorites(String userId) async {
    final db = await instance.database;
    final results = await db.query('favorites', where: 'userId = ?', whereArgs: [userId]);
    return results.map((e) => e['productId'] as String).toList();
  }

  Future<Map<String, dynamic>?> readVoucher(String code) async {
    final db = await instance.database;
    final result = await db.query('vouchers', where: 'code = ?', whereArgs: [code]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateVoucher(Map<String, dynamic> voucher) async {
    final db = await instance.database;
    await db.update('vouchers', voucher, where: 'code = ?', whereArgs: [voucher['code']]);
  }

  Future<void> deleteVoucher(String code) async {
    final db = await instance.database;
    await db.delete('vouchers', where: 'code = ?', whereArgs: [code]);
  }

  // --- Auth Operations ---
  Future<UserModel> registerUser(UserModel user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return user;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }

    // Fallback: Default Admin Login
    if ((email == 'admin@gmail.com' || email == 'admin') && password == 'admin') {
      final defaultAdmin = UserModel(
        id: 'admin-default',
        name: 'Administrator',
        email: 'admin@gmail.com',
        password: 'admin',
        role: 'admin',
      );
      await registerUser(defaultAdmin);
      return defaultAdmin;
    }

    return null;
  }

  Future<List<UserModel>> readAllUsersByRole(String role) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'role = ?', whereArgs: [role]);
    return result.map((json) => UserModel.fromMap(json)).toList();
  }

  // --- CRUD Operations for Banners ---
  Future<void> createBanner(BannerModel banner) async {
    final db = await instance.database;
    await db.insert('banners', banner.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BannerModel>> readAllBanners() async {
    final db = await instance.database;
    final result = await db.query('banners');
    return result.map((json) => BannerModel.fromMap(json)).toList();
  }

  Future<void> deleteBanner(String id) async {
    final db = await instance.database;
    await db.delete('banners', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Operations for Toppings ---
  Future<void> createTopping(Topping topping) async {
    final db = await instance.database;
    await db.insert('toppings', topping.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Topping>> readAllToppings() async {
    try {
      final db = await instance.database;
      final result = await db.query('toppings');
      if (result.isNotEmpty) {
        return result.map((json) => Topping.fromMap(json)).toList();
      }
    } catch (_) {}
    return defaultSeedToppings;
  }

  Future<List<Topping>> readToppingsByCategory(String productCategory) async {
    final allToppings = await readAllToppings();
    final cat = productCategory.toLowerCase();

    bool isFood = cat.contains('makan') || cat.contains('snack') || cat.contains('food') || cat.contains('roti') || cat.contains('dessert');
    bool isDrink = cat.contains('kopi') || cat.contains('minum') || cat.contains('drink') || cat.contains('tea') || cat.contains('frappe') || cat.contains('milk') || cat.contains('juara') || cat.contains('latte');

    return allToppings.where((t) {
      final tCat = t.category.toLowerCase();
      if (tCat == 'semua') return true;
      if (isFood && tCat.contains('makan')) return true;
      if (isDrink && tCat.contains('minum')) return true;
      if (!isFood && !isDrink) return true;
      return false;
    }).toList();
  }

  Future<void> updateTopping(Topping topping) async {
    final db = await instance.database;
    await db.update('toppings', topping.toMap(), where: 'id = ?', whereArgs: [topping.id]);
  }

  Future<void> deleteTopping(String id) async {
    final db = await instance.database;
    await db.delete('toppings', where: 'id = ?', whereArgs: [id]);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUserPoints(String userId, int pointsToAdd) async {
    final db = await instance.database;
    final user = await getUserById(userId);
    if (user != null) {
      final newPoints = user.points + pointsToAdd;
      await db.update(
        'users',
        {'points': newPoints},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return newPoints;
    }
    return 0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
