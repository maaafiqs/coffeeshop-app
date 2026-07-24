import '../../../product/data/models/product_model.dart';
import '../../../product/data/models/topping_model.dart';

class CartItem {
  final Product product;
  int quantity;
  final List<Topping> selectedToppings;
  final String notes;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedToppings = const [],
    this.notes = '',
  });

  double get unitPrice {
    final toppingsPrice = selectedToppings.fold(0.0, (sum, t) => sum + t.price);
    return product.price + toppingsPrice;
  }

  double get subtotal => unitPrice * quantity;

  String get toppingsText {
    if (selectedToppings.isEmpty) return '';
    return selectedToppings.map((t) => t.name).join(', ');
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    List<Topping>? selectedToppings,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      notes: notes ?? this.notes,
    );
  }
}
