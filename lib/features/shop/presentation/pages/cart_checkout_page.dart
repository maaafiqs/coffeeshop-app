import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database_helper.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../admin/data/models/voucher_model.dart';

class CartCheckoutPage extends StatefulWidget {
  const CartCheckoutPage({super.key});

  @override
  State<CartCheckoutPage> createState() => _CartCheckoutPageState();
}

class _CartCheckoutPageState extends State<CartCheckoutPage> {
  final TextEditingController _voucherController = TextEditingController();

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;

    final voucherData = await DatabaseHelper.instance.readVoucher(code);
    if (voucherData != null) {
      final voucher = VoucherModel.fromMap(voucherData);
      final subtotal = context.read<CartCubit>().state.subtotal;

      if (!voucher.isActive) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voucher sudah tidak aktif'), backgroundColor: Colors.red));
        return;
      }

      if (subtotal < voucher.minPurchase) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Minimal pembelian ${formatRupiah(voucher.minPurchase)}'), backgroundColor: Colors.orange));
        return;
      }

      if (mounted) {
        context.read<CartCubit>().applyVoucher(voucher);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voucher berhasil digunakan!'), backgroundColor: Colors.green));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode voucher tidak ditemukan'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => context.read<CartCubit>().clearCart(),
          )
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.brown.shade200),
                  const SizedBox(height: 16),
                  const Text('Keranjang Anda Kosong', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text('Gunakan navigasi di bawah untuk kembali ke Beranda', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[200]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(formatRupiah(item.product.price), style: const TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => context.read<CartCubit>().decreaseQuantity(item.product),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFF5D4037)),
                                onPressed: () => context.read<CartCubit>().addProduct(item.product),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Checkout Panel
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Voucher Input Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _voucherController,
                              decoration: InputDecoration(
                                hintText: 'Punya kode voucher?',
                                hintStyle: const TextStyle(fontSize: 14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8D6E63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onPressed: _applyVoucher,
                            child: const Text('Terapkan'),
                          ),
                        ],
                      ),
                      if (state.appliedVoucher != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Voucher: ${state.appliedVoucher!.code}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              InkWell(
                                onTap: () {
                                  _voucherController.clear();
                                  context.read<CartCubit>().removeVoucher();
                                },
                                child: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                          Text(formatRupiah(state.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pajak (11%)', style: TextStyle(color: Colors.grey)),
                          Text(formatRupiah(state.tax), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (state.discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon', style: TextStyle(color: Colors.green)),
                            Text('- ${formatRupiah(state.discount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(formatRupiah(state.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF3E2723))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2723),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 5,
                          ),
                          onPressed: () async {
                            try {
                              final state = context.read<CartCubit>().state;
                              final newTransaction = TransactionRecord(
                                id: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
                                date: DateTime.now(),
                                subtotal: state.subtotal,
                                tax: state.tax,
                                discount: state.discount,
                                total: state.total,
                                paymentAmount: state.total, // Dummy payment amount
                                change: 0.0,
                              );
                              await DatabaseHelper.instance.createTransaction(newTransaction);

                              if (context.mounted) {
                                context.read<CartCubit>().clearCart();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pembayaran Berhasil! Pesanan tersimpan di riwayat.'), backgroundColor: Colors.green),
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
                          child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
