import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/product/data/models/topping_model.dart';
import '../../features/auth/data/models/user_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  
  bool get _isSupported => kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  FirestoreService._init();

  // --- Transactions (Real-Time Order Sync) ---

  Future<void> saveTransaction(TransactionRecord transaction) async {
    if (!_isSupported) return;
    try {
      await FirebaseFirestore.instance.collection('transactions').doc(transaction.id).set(transaction.toMap());
    } catch (_) {}
  }

  Stream<List<TransactionRecord>> streamUserTransactions(String userId) {
    if (!_isSupported) return const Stream.empty();
    return FirebaseFirestore.instance
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
    if (!_isSupported) return const Stream.empty();
    return FirebaseFirestore.instance.collection('transactions').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => TransactionRecord.fromMap(doc.data())).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> updateTransactionStatus(String transactionId, String newStatus) async {
    if (!_isSupported) return;
    try {
      await FirebaseFirestore.instance.collection('transactions').doc(transactionId).update({'status': newStatus});
    } catch (_) {}
  }

  // --- Users & Loyalty Points ---

  Future<void> saveUser(UserModel user) async {
    if (!_isSupported) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap());
    } catch (_) {}
  }

  Future<void> updateUserPoints(String userId, int newTotalPoints) async {
    if (!_isSupported) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'points': newTotalPoints});
    } catch (_) {}
  }

  // --- Products & Toppings Sync ---

  Future<void> saveProduct(Product product) async {
    if (!_isSupported) return;
    try {
      await FirebaseFirestore.instance.collection('products').doc(product.id).set(product.toMap());
    } catch (_) {}
  }

  Stream<List<Product>> streamProducts() {
    if (!_isSupported) return const Stream.empty();
    return FirebaseFirestore.instance.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }

  Future<void> saveTopping(Topping topping) async {
    if (!_isSupported) return;
    try {
      await FirebaseFirestore.instance.collection('toppings').doc(topping.id).set(topping.toMap());
    } catch (_) {}
  }
}
