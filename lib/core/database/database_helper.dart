import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../features/product/data/models/product_model.dart';
import '../../../features/transaction/data/models/transaction_model.dart';
import '../../../features/auth/data/models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('coffee_shop.db');
    
    // Safety check to ensure transactions table always exists
    await _database!.execute('''
CREATE TABLE IF NOT EXISTS transactions (
  id TEXT PRIMARY KEY,
  date TEXT NOT NULL,
  subtotal REAL NOT NULL,
  tax REAL NOT NULL,
  discount REAL NOT NULL,
  total REAL NOT NULL,
  paymentAmount REAL NOT NULL,
  change REAL NOT NULL,
  items TEXT
)
''');
    
    // Auto-migration check: add items column if missing in older DB instances
    try {
      await _database!.execute('ALTER TABLE transactions ADD COLUMN items TEXT');
    } catch (_) {}
    
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 6,
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
CREATE TABLE users (
  id $idType,
  name $textType,
  email $textType,
  password $textType,
  role $textType
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
  userId TEXT
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

    // Seeding Initial Data for Coffee Shop
    final initialProducts = [
      Product(
        id: 'CFF-001',
        name: 'Caramel Macchiato',
        description: 'Perpaduan sempurna antara espresso tajam, susu creamy, dan sirup karamel manis yang memanjakan lidah.',
        category: 'Coffee',
        price: 35000,
        stock: 50,
        imageUrl: 'https://images.unsplash.com/photo-1485808191679-5f86510681a2?q=80&w=600&auto=format&fit=crop', // Kopi estetik
      ),
      Product(
        id: 'CFF-002',
        name: 'Matcha Latte',
        description: 'Teh hijau matcha Jepang otentik dengan susu segar manis. Menenangkan dan penuh antioksidan.',
        category: 'Non-Coffee',
        price: 32000,
        stock: 40,
        imageUrl: 'https://images.unsplash.com/photo-1536514072410-5019a3c69182?q=80&w=600&auto=format&fit=crop', // Matcha
      ),
      Product(
        id: 'CFF-003',
        name: 'Iced Americano',
        description: 'Klasik, murni, dan menyegarkan. Espresso khas house blend kami yang disajikan dengan es batu.',
        category: 'Coffee',
        price: 25000,
        stock: 100,
        imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=600&auto=format&fit=crop', // Americano
      ),
      Product(
        id: 'CFF-004',
        name: 'Mocha Frappuccino',
        description: 'Blended ice coffee dengan saus cokelat tebal dan whipped cream di atasnya. Surganya para pecinta cokelat.',
        category: 'Frappe',
        price: 40000,
        stock: 30,
        imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?q=80&w=600&auto=format&fit=crop', // Frappe
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
    final db = await instance.database;
    final orderBy = 'name ASC';
    final result = await db.query('products', orderBy: orderBy);
    return result.map((json) => Product.fromMap(json)).toList();
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
    const orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);
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
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
