class Topping {
  final String id;
  final String name;
  final double price;
  final String category; // 'Minuman', 'Makanan', or 'Semua'

  const Topping({
    required this.id,
    required this.name,
    required this.price,
    this.category = 'Semua',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
    };
  }

  factory Topping.fromMap(Map<String, dynamic> map) {
    return Topping(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Semua',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topping &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

final List<Topping> defaultSeedToppings = [
  const Topping(id: 't1', name: 'Extra Shot Espresso', price: 5000, category: 'Minuman'),
  const Topping(id: 't2', name: 'Whipped Cream', price: 4000, category: 'Minuman'),
  const Topping(id: 't3', name: 'Boba / Pearl', price: 5000, category: 'Minuman'),
  const Topping(id: 't4', name: 'Cheese Cream', price: 6000, category: 'Minuman'),
  const Topping(id: 't5', name: 'Caramel Syrup', price: 4000, category: 'Minuman'),
  const Topping(id: 't6', name: 'Ice Cream Vanilla', price: 7000, category: 'Minuman'),
  const Topping(id: 't7', name: 'Extra Keju', price: 5000, category: 'Makanan'),
  const Topping(id: 't8', name: 'Extra Telur', price: 4000, category: 'Makanan'),
  const Topping(id: 't9', name: 'Sambal Extra', price: 3000, category: 'Makanan'),
  const Topping(id: 't10', name: 'Saus Keju', price: 4000, category: 'Makanan'),
];
