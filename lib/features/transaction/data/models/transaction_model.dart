class TransactionRecord {
  final String id;
  final DateTime date;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double paymentAmount;
  final double change;

  TransactionRecord({
    required this.id,
    required this.date,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentAmount,
    required this.change,
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
    };
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      paymentAmount: (map['paymentAmount'] ?? 0.0).toDouble(),
      change: (map['change'] ?? 0.0).toDouble(),
    );
  }
}
