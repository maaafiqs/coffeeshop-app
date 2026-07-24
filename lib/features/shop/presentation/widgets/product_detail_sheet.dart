import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../pos/data/models/cart_item_model.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/data/models/topping_model.dart';
import '../cubit/favorite_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database_helper.dart';

class ProductDetailSheet extends StatefulWidget {
  final Product product;
  final List<Topping>? initialToppings;
  final int initialQuantity;
  final CartItem? existingCartItem;

  const ProductDetailSheet({
    super.key,
    required this.product,
    this.initialToppings,
    this.initialQuantity = 1,
    this.existingCartItem,
  });

  static void show(
    BuildContext context,
    Product product, {
    List<Topping>? initialToppings,
    int initialQuantity = 1,
    CartItem? existingCartItem,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailSheet(
        product: product,
        initialToppings: initialToppings,
        initialQuantity: initialQuantity,
        existingCartItem: existingCartItem,
      ),
    );
  }

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  final List<Topping> _selectedToppings = [];
  List<Topping> _toppingsForCategory = [];
  bool _isLoadingToppings = true;
  int _quantity = 1;
  late TextEditingController _notesController;

  final List<String> _quickNotes = ['Less Sugar', 'Less Ice', 'Normal', 'Extra Ice', 'Panas/Hot', 'Take Away'];

  @override
  void initState() {
    super.initState();
    if (widget.initialToppings != null) {
      _selectedToppings.addAll(widget.initialToppings!);
    }
    _quantity = widget.initialQuantity;
    _notesController = TextEditingController(text: widget.existingCartItem?.notes ?? '');
    _loadToppings();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadToppings() async {
    final list = await DatabaseHelper.instance.readToppingsByCategory(widget.product.category);
    if (mounted) {
      setState(() {
        _toppingsForCategory = list;
        _isLoadingToppings = false;
      });
    }
  }

  double get _unitPrice {
    final toppingSum = _selectedToppings.fold(0.0, (sum, t) => sum + t.price);
    return widget.product.price + toppingSum;
  }

  double get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCartItem != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            
            // Product Image with category badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.product.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.product.category,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Name and Favorite Heart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                  ),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
                    return BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, favoriteState) {
                        final isFavorite = context.read<FavoriteCubit>().isFavorite(widget.product.id);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () {
                            final wasFav = isFavorite;
                            context.read<FavoriteCubit>().toggleFavorite(authState.user.id, widget.product.id);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(!wasFav ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        !wasFav
                                            ? '${widget.product.name} ditambahkan ke favorit'
                                            : '${widget.product.name} dihapus dari favorit',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: !wasFav ? Colors.redAccent : const Color(0xFF8D6E63),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            
            // Base price display
            Text(
              formatRupiah(widget.product.price),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5D4037)),
            ),
            const SizedBox(height: 16),
            
            // Description section
            const Text(
              'Deskripsi Produk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
            ),
            const SizedBox(height: 6),
            Text(
              widget.product.description.isNotEmpty ? widget.product.description : 'Tidak ada deskripsi tersedia.',
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 20),
            
            // Toppings selection section (Category-Specific)
            if (_isLoadingToppings)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Color(0xFF5D4037))))
            else if (_toppingsForCategory.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Modifikasi Topping / Ekstra',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(Opsional)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _toppingsForCategory.map((topping) {
                  final isSelected = _selectedToppings.contains(topping);
                  return FilterChip(
                    label: Text('${topping.name} (+${formatRupiah(topping.price)})'),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD7CCC8),
                    checkmarkColor: const Color(0xFF3E2723),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF5D4037) : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3E2723) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedToppings.add(topping);
                        } else {
                          _selectedToppings.remove(topping);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            
            // Catatan Pesanan Section
            Row(
              children: [
                const Text(
                  'Catatan Pesanan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                ),
                const SizedBox(width: 8),
                Text(
                  '(Opsional)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickNotes.map((note) {
                final currentText = _notesController.text;
                final isSelected = currentText.contains(note);
                return ActionChip(
                  label: Text(note),
                  backgroundColor: isSelected ? const Color(0xFF5D4037) : Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isSelected) {
                        _notesController.text = currentText.replaceAll(note, '').replaceAll(', ,', ',').trim();
                        if (_notesController.text.startsWith(',')) {
                          _notesController.text = _notesController.text.substring(1).trim();
                        }
                      } else {
                        if (_notesController.text.isEmpty) {
                          _notesController.text = note;
                        } else {
                          _notesController.text = '${_notesController.text}, $note';
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Contoh: Less Sugar, es dipisah, ekstra panas...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF5D4037)),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            
            // Quantity & Total Price Add Button Row
            Row(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Add to Cart / Update Button with total price
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4037),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        final authState = context.read<AuthCubit>().state;
                        if (authState is! AuthAuthenticated) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          showDialog(
                            context: context,
                            builder: (ctx2) => AlertDialog(
                              title: const Text('Silakan Login', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                              content: const Text('Anda harus login terlebih dahulu untuk menambahkan produk ke keranjang.'),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(ctx2);
                                    Navigator.pushReplacementNamed(context, '/');
                                  },
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        
                        if (isEditing) {
                          // Update existing cart item
                          context.read<CartCubit>().replaceCartItem(
                            widget.existingCartItem!,
                            toppings: _selectedToppings,
                            quantity: _quantity,
                            notes: _notesController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text('Pesanan ${widget.product.name} berhasil diperbarui!'),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF8D6E63),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } else {
                          // Add new item to cart
                          context.read<CartCubit>().addProduct(
                            widget.product,
                            toppings: _selectedToppings,
                            quantity: _quantity,
                            notes: _notesController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedToppings.isNotEmpty
                                          ? '${widget.product.name} (${_selectedToppings.length} topping) ditambahkan!'
                                          : '${widget.product.name} ditambahkan!',
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF8D6E63),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      icon: Icon(isEditing ? Icons.save : Icons.add_shopping_cart, size: 20),
                      label: Text(
                        isEditing
                            ? 'Simpan Perubahan • ${formatRupiah(_totalPrice)}'
                            : 'Pesan • ${formatRupiah(_totalPrice)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
