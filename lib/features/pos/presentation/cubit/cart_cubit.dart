import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/data/models/topping_model.dart';
import '../../../admin/data/models/voucher_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  final double taxRate = 0.11; // PPN 11%

  void addProduct(Product product, {List<Topping> toppings = const [], int quantity = 1, String notes = ''}) {
    final currentItems = List<CartItem>.from(state.items);
    final toppingIds = toppings.map((t) => t.id).toSet();

    final existingIndex = currentItems.indexWhere((item) {
      if (item.product.id != product.id) return false;
      if (item.notes != notes) return false;
      final itemToppingIds = item.selectedToppings.map((t) => t.id).toSet();
      return toppingIds.length == itemToppingIds.length && toppingIds.containsAll(itemToppingIds);
    });

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += quantity;
    } else {
      currentItems.add(CartItem(
        product: product,
        quantity: quantity,
        selectedToppings: List.from(toppings),
        notes: notes,
      ));
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

  void decreaseCartItem(CartItem item) {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexOf(item);

    if (existingIndex >= 0) {
      if (currentItems[existingIndex].quantity > 1) {
        currentItems[existingIndex].quantity -= 1;
      } else {
        currentItems.removeAt(existingIndex);
      }
      _calculateAndEmit(currentItems);
    }
  }

  void increaseCartItem(CartItem item) {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexOf(item);

    if (existingIndex >= 0) {
      currentItems[existingIndex].quantity += 1;
      _calculateAndEmit(currentItems);
    }
  }

  void replaceCartItem(CartItem oldItem, {required List<Topping> toppings, required int quantity, String notes = ''}) {
    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexOf(oldItem);
    if (existingIndex >= 0) {
      currentItems[existingIndex] = oldItem.copyWith(
        selectedToppings: List.from(toppings),
        quantity: quantity,
        notes: notes,
      );
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
    VoucherModel? currentVoucher = appliedVoucher ?? state.appliedVoucher;

    double subtotal = items.fold(0, (sum, item) => sum + item.subtotal);
    double tax = subtotal * taxRate;
    
    double discount = 0;
    if (currentVoucher != null) {
      if (subtotal >= currentVoucher.minPurchase) {
        discount = currentVoucher.calculateDiscount(subtotal);
      } else {
        currentVoucher = null;
      }
    }

    double total = (subtotal + tax) - discount;
    if (total < 0) total = 0;

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
