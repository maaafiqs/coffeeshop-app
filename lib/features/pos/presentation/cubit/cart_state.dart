part of 'cart_cubit.dart';

class CartState {
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount; // Tambahkan discount
  final double total;
  final VoucherModel? appliedVoucher; // Tambahkan referensi voucher

  CartState({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    this.appliedVoucher,
  });

  factory CartState.initial() => CartState(
        items: [],
        subtotal: 0,
        tax: 0,
        discount: 0,
        total: 0,
        appliedVoucher: null,
      );
}
