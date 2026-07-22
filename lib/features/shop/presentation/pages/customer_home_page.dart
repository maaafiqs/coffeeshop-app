import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../product/presentation/cubit/product_state.dart';
import '../../../product/data/models/product_model.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'cart_checkout_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Coffee', 'Non-Coffee', 'Frappe'];

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductCubit>().fetchProducts();
          // Optional: Add a small delay for better UX
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: const Color(0xFF5D4037),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFFAF6F0),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'Maaafiqs Coffee',
                  style: TextStyle(
                    color: Color(0xFF3E2723),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                background: Container(
                  color: const Color(0xFFFAF6F0),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(left: 20, bottom: 55),
                  child: const Text('Selamat datang kembali,', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF3E2723)),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Smart Cart Notification Banner
            SliverToBoxAdapter(
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  
                  final int totalItems = state.items.fold(0, (sum, item) => sum + item.quantity);
                  
                  return Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D4037).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_rounded, color: Color(0xFF5D4037)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Hei, ada $totalItems pesanan di keranjangmu. Cek sekarang!',
                            style: const TextStyle(
                              color: Color(0xFF3E2723),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF5D4037)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Horizontal Info Section (Coffee & Non-Coffee)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Text(
                      'Jelajahi Rasa 🍃',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildInfoCard(
                          title: 'Kopi Nusantara',
                          subtitle: 'Biji kopi pilihan dari petani lokal dengan roasting profile terbaik.',
                          color: const Color(0xFF5D4037),
                          icon: Icons.coffee_maker_rounded,
                        ),
                        _buildInfoCard(
                          title: 'Non-Coffee',
                          subtitle: 'Pilihan teh, cokelat, dan susu segar untuk menyejukkan harimu.',
                          color: const Color(0xFF8D6E63),
                          icon: Icons.local_drink_rounded,
                        ),
                        _buildInfoCard(
                          title: 'Promo Spesial',
                          subtitle: 'Dapatkan diskon 20% setiap pembelian di atas Rp 100.000.',
                          color: const Color(0xFFD4A373),
                          icon: Icons.local_offer_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari minuman kesukaanmu...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                            selectedColor: const Color(0xFF5D4037),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF3E2723),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Menu Pilihan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Product Grid
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF5D4037))),
                  );
                } else if (state is ProductError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Terjadi Kesalahan: ${state.message}')),
                  );
                } else if (state is ProductLoaded) {
                  
                  // Filter Products
                  List<Product> filteredProducts = state.products.where((product) {
                    final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesCategory = _selectedCategory == 'Semua' || product.category.toLowerCase() == _selectedCategory.toLowerCase();
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('Menu tidak ditemukan', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(context, product);
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            
            // Extra space at bottom to avoid overlap
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle, required Color color, required IconData icon}) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Tentukan warna tag kategori (Kopi vs Non-Kopi)
    final isCoffee = product.category.toLowerCase().contains('coffee') || product.category.toLowerCase().contains('frappe');
    final tagColor = isCoffee ? const Color(0xFF5D4037) : const Color(0xFF4CAF50);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Detail Produk
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        formatRupiah(product.price),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF5D4037)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<CartCubit>().addProduct(product);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 10),
                                Expanded(child: Text('${product.name} ditambahkan!')),
                              ],
                            ),
                            backgroundColor: const Color(0xFF8D6E63),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D4037),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
