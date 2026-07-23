import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../product/presentation/cubit/product_state.dart';
import '../../../product/data/models/product_model.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database_helper.dart';
import '../../../admin/data/models/banner_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class CustomerHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToCart;
  const CustomerHomePage({super.key, this.onNavigateToCart});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Coffee', 'Non-Coffee', 'Frappe', 'Snack'];

  List<BannerModel> _banners = [];
  bool _isLoadingBanners = true;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final banners = await DatabaseHelper.instance.readAllBanners();
    if (mounted) {
      setState(() {
        _banners = banners.where((b) => b.isActive).toList();
        _isLoadingBanners = false;
      });
    }
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
                  
                  return InkWell(
                    onTap: widget.onNavigateToCart,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
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
                  // Horizontal Info List
                  SizedBox(
                    height: 140,
                    child: _isLoadingBanners
                        ? const Center(child: CircularProgressIndicator())
                        : _banners.isEmpty
                            ? Center(
                                child: Text('Belum ada info terbaru', style: TextStyle(color: Colors.grey.shade600)),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _banners.length,
                                itemBuilder: (context, index) {
                                  final banner = _banners[index];
                                  return Container(
                                    width: 280,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5D4037),
                                      borderRadius: BorderRadius.circular(16),
                                      image: banner.imageUrl != 'default'
                                          ? DecorationImage(
                                              image: NetworkImage(banner.imageUrl),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.brown.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        )
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          banner.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          banner.subtitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(product.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 200, color: Colors.grey.shade200)),
            ),
            const SizedBox(height: 16),
            Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
            const SizedBox(height: 8),
            Text(formatRupiah(product.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5D4037))),
            const SizedBox(height: 16),
            Text(product.description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  final authState = context.read<AuthCubit>().state;
                  if (authState is! AuthAuthenticated) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    showDialog(
                      context: context,
                      builder: (ctx2) => AlertDialog(
                        title: const Text('Silakan Login', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                        content: const Text('Anda harus login atau mendaftar terlebih dahulu untuk melakukan pemesanan.'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.pop(ctx2);
                              Navigator.pushReplacementNamed(context, '/'); 
                            },
                            child: const Text('Mengerti'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  _showAddToCartDialog(context, product);
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Pesan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, Product product) {
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
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Tentukan warna tag kategori (Kopi vs Non-Kopi)
    final isCoffee = product.category.toLowerCase().contains('coffee') || product.category.toLowerCase().contains('frappe');
    final tagColor = isCoffee ? const Color(0xFF5D4037) : const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      child: Container(
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
                        final authState = context.read<AuthCubit>().state;
                        if (authState is! AuthAuthenticated) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Silakan Login', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                              content: const Text('Anda harus login atau mendaftar terlebih dahulu untuk melakukan pemesanan.'),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5D4037),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pushReplacementNamed(context, '/'); // Go to role selection / login
                                  },
                                  child: const Text('Login Sekarang'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

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
    ));
  }
}
