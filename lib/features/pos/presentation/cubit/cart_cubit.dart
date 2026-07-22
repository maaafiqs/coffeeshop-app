import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../admin/data/models/voucher_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  final double taxRate = 0.11; // PPN 11%

  void addProduct(Product product) {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += 1;
    } else {
      currentItems.add(CartItem(product: product));
    }
    _calculateAndEmit(currentItems);
  }

  void decreaseQuantity(Product product) {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      if (currentItems[existingIndex].quantity > 1) {
        currentItems[existingIndex].quantity -= 1;
      } else {
        currentItems.removeAt(existingIndex);
      }
      _calculateAndEmit(currentItems);
    }
  }

  void applyVoucher(VoucherModel voucher) {
    _calculateAndEmit(state.items, appliedVoucher: voucher);
  }

  void removeVoucher() {
    _calculateAndEmit(state.items, appliedVoucher: null);
  }

  void clearCart() => emit(CartState.initial());

  void _calculateAndEmit(List<CartItem> items, {VoucherModel? appliedVoucher}) {
    // Retain existing voucher if not explicitly provided but still valid
    VoucherModel? currentVoucher = appliedVoucher ?? state.appliedVoucher;

    double subtotal = items.fold(0, (sum, item) => sum + item.subtotal);
    double tax = subtotal * taxRate;
    
    // Calculate discount
    double discount = 0;
    if (currentVoucher != null) {
      if (subtotal >= currentVoucher.minPurchase) {
        discount = currentVoucher.calculateDiscount(subtotal);
      } else {
        // Remove voucher if minimum purchase is no longer met
        currentVoucher = null;
      }
    }

    double total = (subtotal + tax) - discount;
    if (total < 0) total = 0; // Prevent negative total

    emit(CartState(
      items: items,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      appliedVoucher: currentVoucher,
    ));
  }
}
