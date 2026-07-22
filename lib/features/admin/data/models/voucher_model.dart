class VoucherModel {
  final String code;
  final String discountType; // 'nominal' or 'percentage'
  final double discountValue; // Amount (e.g., 10000) or Percentage (e.g., 20)
  final double minPurchase;
  final bool isActive;

  VoucherModel({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase(),
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchase': minPurchase,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      code: map['code'],
      discountType: map['discountType'],
      discountValue: map['discountValue'],
      minPurchase: map['minPurchase'],
      isActive: map['isActive'] == 1,
    );
  }

  double calculateDiscount(double subtotal) {
    if (!isActive || subtotal < minPurchase) {
      return 0.0;
    }

    if (discountType == 'percentage') {
      // Calculate percentage discount
      final discount = subtotal * (discountValue / 100);
      return discount;
    } else {
      // Nominal discount
      return discountValue > subtotal ? subtotal : discountValue;
    }
  }
}
