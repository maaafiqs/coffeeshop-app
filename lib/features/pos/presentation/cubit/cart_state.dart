part of 'cart_cubit.dart';

class CartState {
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;

  CartState({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  factory CartState.initial() => CartState(
        items: [],
        subtotal: 0,
        tax: 0,
        total: 0,
      );
}
