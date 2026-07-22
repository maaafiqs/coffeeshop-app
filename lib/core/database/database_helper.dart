import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../features/product/data/models/product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('coffee_shop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
