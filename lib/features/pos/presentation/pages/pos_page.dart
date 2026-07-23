import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cart_cubit.dart';
import '../../../product/data/models/product_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database_helper.dart';
import '../../../transaction/data/models/transaction_model.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengecek lebar layar untuk responsivitas
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Kasir'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: isDesktop ? _buildTabletLayout(context) : _buildMobileLayout(context),
      // Di mobile, tampilkan tombol untuk melihat keranjang
      floatingActionButton: isDesktop ? null : BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: Colors.blue.shade800,
            onPressed: () => _showMobileCart(context),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              '${state.items.length} Item - ${formatRupiah(state.total)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildProductCatalog(crossAxisCount: 2);
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildProductCatalog(crossAxisCount: 3),
        ),
        Expanded(
          flex: 1,
          child: _buildCartPanel(),
        )
      ],
    );
  }

  Widget _buildProductCatalog({required int crossAxisCount}) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final mockProduct = Product(
            id: 'PROD-$index',
            name: 'Produk Premium $index',
            description: 'Deskripsi produk kasir',
            category: 'Umum',
            price: 15000.0 + (index * 5000),
            stock: 100,
            imageUrl: '');

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.read<CartCubit>().addProduct(mockProduct),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2, size: 40, color: Colors.blueGrey),
                  const SizedBox(height: 8),
                  Text(
                    mockProduct.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(mockProduct.price),
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: const Text(
              'Keranjang Belanja',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(formatRupiah(item.product.price), style: const TextStyle(fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => context.read<CartCubit>().decreaseQuantity(item.product),
                          ),
                          Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () => context.read<CartCubit>().addProduct(item.product),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Ringkasan Pembayaran
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:', style: TextStyle(color: Colors.grey.shade700)),
                          Text(formatRupiah(state.subtotal))
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pajak (11%):', style: TextStyle(color: Colors.grey.shade700)),
                          Text(formatRupiah(state.tax))
                        ]),
                    const Divider(height: 24),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(formatRupiah(state.total),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade800))
                        ]),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: state.items.isEmpty
                            ? null
                            : () async {
                                try {
                                  final newTransaction = TransactionRecord(
                                    id: 'TRX-ADM-${DateTime.now().millisecondsSinceEpoch}',
                                    date: DateTime.now(),
                                    subtotal: state.subtotal,
                                    tax: state.tax,
                                    discount: state.discount,
                                    total: state.total,
                                    paymentAmount: state.total,
                                    change: 0.0,
                                    userId: 'admin',
                                    items: state.items
                                        .map((item) => OrderItemRecord(
                                              productId: item.product.id,
                                              productName: item.product.name,
                                              price: item.product.price,
                                              quantity: item.quantity,
                                              imageUrl: item.product.imageUrl,
                                            ))
                                        .toList(),
                                  );
                                  await DatabaseHelper.instance.createTransaction(newTransaction);
                                  
                                  if (context.mounted) {
                                    context.read<CartCubit>().clearCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Pembayaran Berhasil!'), backgroundColor: Colors.green),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal checkout: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        child: const Text('BAYAR SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: _buildCartPanel(),
          ),
        );
      },
    );
  }
}
