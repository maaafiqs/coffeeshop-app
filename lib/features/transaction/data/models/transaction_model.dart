import 'dart:convert';
import '../../../product/data/models/topping_model.dart';

class OrderItemRecord {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final List<Topping> toppings;
  final String notes;

  OrderItemRecord({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.toppings = const [],
    this.notes = '',
  });

  double get subtotal => price * quantity;

  String get toppingsText {
    if (toppings.isEmpty) return '';
    return toppings.map((t) => t.name).join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'toppings': toppings.map((t) => t.toMap()).toList(),
      'notes': notes,
    };
  }

  factory OrderItemRecord.fromMap(Map<String, dynamic> map) {
    List<Topping> parsedToppings = [];
    if (map['toppings'] != null && map['toppings'] is List) {
      try {
        parsedToppings = (map['toppings'] as List).map((t) => Topping.fromMap(t as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return OrderItemRecord(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      imageUrl: map['imageUrl'],
      toppings: parsedToppings,
      notes: map['notes'] ?? '',
    );
  }
}

class TransactionRecord {
  final String id;
  final DateTime date;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double paymentAmount;
  final double change;
  final List<OrderItemRecord> items;
  final String? userId;
  final String status; // 'pending', 'preparing', 'ready', 'completed'

  TransactionRecord({
    required this.id,
    required this.date,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentAmount,
    required this.change,
    this.items = const [],
    this.userId,
    this.status = 'completed',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentAmount': paymentAmount,
      'change': change,
      'items': jsonEncode(items.map((x) => x.toMap()).toList()),
      'userId': userId,
      'status': status,
    };
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    List<OrderItemRecord> parsedItems = [];
    if (map['items'] != null && map['items'] is String && (map['items'] as String).isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(map['items']);
        parsedItems = decoded.map((x) => OrderItemRecord.fromMap(x as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return TransactionRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      paymentAmount: (map['paymentAmount'] ?? 0.0).toDouble(),
      change: (map['change'] ?? 0.0).toDouble(),
      items: parsedItems,
      userId: map['userId'],
      status: map['status'] ?? 'completed',
    );
  }
}
