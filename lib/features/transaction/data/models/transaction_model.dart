import 'dart:convert';

class OrderItemRecord {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItemRecord({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItemRecord.fromMap(Map<String, dynamic> map) {
    return OrderItemRecord(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      imageUrl: map['imageUrl'],
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
    );
  }
}

