import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../../../product/presentation/cubit/product_state.dart';
import '../../../product/data/models/product_model.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database_helper.dart';
import '../../../admin/data/models/banner_model.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../cubit/favorite_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/product_detail_sheet.dart';

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

  List<TransactionRecord> _activeOrders = [];
  bool _isLoadingActiveOrders = true;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
    _loadBanners();
    _loadActiveOrders();
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

  Future<void> _loadActiveOrders() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final transactions = await DatabaseHelper.instance.readTransactionsByUser(authState.user.id);
      if (mounted) {
        setState(() {
          _activeOrders = transactions.where((tx) =>
            tx.status.toLowerCase() == 'pending' ||
            tx.status.toLowerCase() == 'preparing' ||
            tx.status.toLowerCase() == 'ready'
          ).toList();
          _isLoadingActiveOrders = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _activeOrders = [];
          _isLoadingActiveOrders = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat pagi,';
    } else if (hour < 15) {
      return 'Selamat siang,';
    } else if (hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pesanan Menunggu Konfirmasi';
      case 'preparing':
        return 'Pesanan Anda Sedang Diproses ☕';
      case 'ready':
        return 'Pesanan Anda Siap Diambil! 🎉';
      default:
        return 'Status Pesanan';
    }
  }

  String _getStatusSubtitle(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pesanan telah diterima & menunggu diproses kasir';
      case 'preparing':
        return 'Barista sedang menyiapkan minuman & makanan Anda';
      case 'ready':
        return 'Silakan ambil pesanan Anda di counter / kasir';
      default:
        return '';
    }
  }

  String _getStatusBadgeText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'MENUNGGU';
      case 'preparing':
        return 'DIPROSES';
      case 'ready':
        return 'SIAP';
      default:
        return status.toUpperCase();
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'preparing':
        return Icons.local_cafe_rounded;
      case 'ready':
        return Icons.check_circle_rounded;
      default:
        return Icons.receipt_long;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade50;
      case 'preparing':
        return Colors.blue.shade50;
      case 'ready':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'preparing':
        return Colors.blue.shade800;
      case 'ready':
        return Colors.green.shade800;
      default:
        return Colors.black87;
    }
  }

  Color _getCardBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade300;
      case 'preparing':
        return Colors.blue.shade300;
      case 'ready':
        return Colors.green.shade400;
      default:
        return const Color(0xFF5D4037).withOpacity(0.3);
    }
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  void _showOrderDetailModal(BuildContext context, TransactionRecord tx) {
    final totalItemsCount = tx.items.fold<int>(0, (sum, item) => sum + item.quantity);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Detail Pesanan Aktif', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF3E2723)), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
                                const SizedBox(height: 4),
                                Text(_formatDate(tx.date), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _getStatusBgColor(tx.status), borderRadius: BorderRadius.circular(12)),
                              child: Text(_getStatusBadgeText(tx.status), style: TextStyle(color: _getStatusTextColor(tx.status), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Daftar Produk ($totalItemsCount Item)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tx.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final item = tx.items[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                                      ? Image.network(item.imageUrl!, width: 54, height: 54, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 54, height: 54, color: const Color(0xFFEFEBE9), child: const Icon(Icons.coffee_rounded, color: Color(0xFF8D6E63))))
                                      : Container(width: 54, height: 54, color: const Color(0xFFEFEBE9), child: const Icon(Icons.coffee_rounded, color: Color(0xFF8D6E63))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
                                      if (item.toppings.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text('+ ${item.toppingsText}', style: const TextStyle(color: Color(0xFF5D4037), fontSize: 12, fontStyle: FontStyle.italic)),
                                      ],
                                      const SizedBox(height: 4),
                                      Text('${formatRupiah(item.price)} × ${item.quantity}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF5D4037))),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text('Rincian Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: Colors.grey)), Text(formatRupiah(tx.subtotal), style: const TextStyle(fontWeight: FontWeight.bold))]),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('PPN (11%)', style: TextStyle(color: Colors.grey)), Text(formatRupiah(tx.tax), style: const TextStyle(fontWeight: FontWeight.bold))]),
                            if (tx.discount > 0) ...[
                              const SizedBox(height: 8),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Diskon Voucher', style: TextStyle(color: Colors.green)), Text('-${formatRupiah(tx.discount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                            ],
                            const Divider(height: 24),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))), Text(formatRupiah(tx.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF5D4037)))]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2723), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductCubit>().fetchProducts();
          _loadBanners();
          _loadActiveOrders();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: const Color(0xFF5D4037),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFFFAF6F0),
              elevation: 0,
              toolbarHeight: 70,
              title: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  String userName = 'Pelanggan';
                  if (state is AuthAuthenticated) {
                    userName = state.user.name.split(' ').first;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()} $userName 👋',
                        style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Maaafiqs Coffee',
                        style: TextStyle(
                          color: Color(0xFF3E2723),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated || state.user.role != 'customer') {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade400, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '${state.user.points} Poin',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFF3E2723)),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Active Order Status Banner (Pesanan Berlangsung)
            SliverToBoxAdapter(
              child: _isLoadingActiveOrders || _activeOrders.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: _getCardBorderColor(_activeOrders.first.status),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(_activeOrders.first.status),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getStatusIcon(_activeOrders.first.status),
                                  color: _getStatusTextColor(_activeOrders.first.status),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getStatusTitle(_activeOrders.first.status),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF3E2723),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getStatusSubtitle(_activeOrders.first.status),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(_activeOrders.first.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusBadgeText(_activeOrders.first.status),
                                  style: TextStyle(
                                    color: _getStatusTextColor(_activeOrders.first.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _activeOrders.first.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      '${item.quantity}x ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF5D4037),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.toppings.isNotEmpty
                                            ? '${item.productName} (+${item.toppingsText})'
                                            : item.productName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      formatRupiah(item.subtotal),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8D6E63),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${formatRupiah(_activeOrders.first.total)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              InkWell(
                                onTap: () => _showOrderDetailModal(context, _activeOrders.first),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5D4037),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Cek Detail',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          banner.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          banner.subtitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari kopi, non-kopi, atau snack...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF5D4037)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.brown.shade100, width: 1),
                    ),
                  ),
                ),
              ),
            ),

            // Category Chips List
            SliverToBoxAdapter(
              child: SizedBox(
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
                        selectedColor: const Color(0xFF5D4037),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF3E2723),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.brown.shade100,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Product Grid Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Menu Pilihan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                ),
              ),
            ),

            // Product Grid Content
            BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF5D4037)),
                    ),
                  );
                } else if (state is ProductLoaded) {
                  final filteredProducts = state.products.where((product) {
                    final matchesSearch = product.name.toLowerCase().contains(_searchQuery) ||
                        product.description.toLowerCase().contains(_searchQuery);
                    final matchesCategory = _selectedCategory == 'Semua' ||
                        product.category.toLowerCase() == _selectedCategory.toLowerCase();
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Produk tidak ditemukan',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
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
                } else if (state is ProductError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Gagal memuat produk: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => ProductDetailSheet.show(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Tag and Favorite Button
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.coffee, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, authState) {
                        if (authState is! AuthAuthenticated) return const SizedBox.shrink();
                        return BlocBuilder<FavoriteCubit, FavoriteState>(
                          builder: (context, favoriteState) {
                            final isFav = context.read<FavoriteCubit>().isFavorite(product.id);
                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.redAccent : Colors.white,
                                size: 22,
                              ),
                              onPressed: () {
                                final wasFav = isFav;
                                context.read<FavoriteCubit>().toggleFavorite(authState.user.id, product.id);
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
                                                ? '${product.name} ditambahkan ke favorit'
                                                : '${product.name} dihapus dari favorit',
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
                  ),
                ],
              ),
            ),
            // Product Information
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatRupiah(product.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D4037),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
