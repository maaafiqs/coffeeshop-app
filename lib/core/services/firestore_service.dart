import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/product/data/models/topping_model.dart';
import '../../features/auth/data/models/user_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService._init();

  // --- Transactions (Real-Time Order Sync) ---

  Future<void> saveTransaction(TransactionRecord transaction) async {
    try {
      await _db.collection('transactions').doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      // Fallback logging
    }
  }

  Stream<List<TransactionRecord>> streamUserTransactions(String userId) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => TransactionRecord.fromMap(doc.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Stream<List<TransactionRecord>> streamAllTransactions() {
    return _db.collection('transactions').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => TransactionRecord.fromMap(doc.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> updateTransactionStatus(String transactionId, String newStatus) async {
    try {
      await _db.collection('transactions').doc(transactionId).update({'status': newStatus});
    } catch (e) {
      // Fallback
    }
  }

  // --- Users & Loyalty Points ---

  Future<void> saveUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (_) {}
  }

  Future<void> updateUserPoints(String userId, int newTotalPoints) async {
    try {
      await _db.collection('users').doc(userId).update({'points': newTotalPoints});
    } catch (_) {}
  }

  // --- Products & Toppings Sync ---

  Future<void> saveProduct(Product product) async {
    try {
      await _db.collection('products').doc(product.id).set(product.toMap());
    } catch (_) {}
  }

  Stream<List<Product>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }

  Future<void> saveTopping(Topping topping) async {
    try {
      await _db.collection('toppings').doc(topping.id).set(topping.toMap());
    } catch (_) {}
  }
}
