import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/database/database_helper.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../admin/data/models/voucher_model.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/product_detail_sheet.dart';
import 'payment_page.dart';

class CartCheckoutPage extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  const CartCheckoutPage({super.key, this.onNavigateToHome});

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

  void _handleTambahMenuLain() {
    if (widget.onNavigateToHome != null) {
      widget.onNavigateToHome!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 90, color: Colors.brown.shade200),
                    const SizedBox(height: 16),
                    const Text('Keranjang Anda Kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                    const SizedBox(height: 8),
                    const Text('Belum ada menu yang ditambahkan ke keranjang.', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D4037),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleTambahMenuLain,
                        icon: const Icon(Icons.restaurant_menu),
                        label: const Text('Pilih Menu Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.items.length + 1, // +1 for "Tambah Menu Lain" button at bottom of list
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    if (i == state.items.length) {
                      // Button "Tambah Menu Lain" under orders list
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5D4037),
                            side: const BorderSide(color: Color(0xFF5D4037), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _handleTambahMenuLain,
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text(
                            'Tambah Menu Lain',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      );
                    }

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
                          GestureDetector(
                            onTap: () => ProductDetailSheet.show(
                              context,
                              item.product,
                              initialToppings: item.selectedToppings,
                              initialQuantity: item.quantity,
                              existingCartItem: item,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[200]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => ProductDetailSheet.show(
                                context,
                                item.product,
                                initialToppings: item.selectedToppings,
                                initialQuantity: item.quantity,
                                existingCartItem: item,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.edit_note, size: 20, color: Color(0xFF8D6E63)),
                                    ],
                                  ),
                                  if (item.selectedToppings.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '+ ${item.toppingsText}',
                                      style: const TextStyle(color: Color(0xFF5D4037), fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                  if (item.notes.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Catatan: "${item.notes}"',
                                      style: TextStyle(color: Colors.brown.shade700, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                  if (item.selectedToppings.isEmpty && item.notes.isEmpty) ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Ketuk untuk edit opsi',
                                      style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(formatRupiah(item.unitPrice), style: const TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () => context.read<CartCubit>().decreaseCartItem(item),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFF5D4037)),
                                onPressed: () => context.read<CartCubit>().increaseCartItem(item),
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
                                hintText: 'Kode Voucher (opsional)',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                suffixIcon: state.appliedVoucher != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.red),
                                        onPressed: () {
                                          context.read<CartCubit>().removeVoucher();
                                          _voucherController.clear();
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5D4037),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _applyVoucher,
                            child: const Text('Gunakan'),
                          ),
                        ],
                      ),
                      if (state.appliedVoucher != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.confirmation_number, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Voucher ${state.appliedVoucher!.code} terpasang (-${formatRupiah(state.discount)})',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                          Text(formatRupiah(state.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PPN (11%)', style: TextStyle(color: Colors.grey)),
                          Text(formatRupiah(state.tax), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (state.discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon Voucher', style: TextStyle(color: Colors.green)),
                            Text('-${formatRupiah(state.discount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(formatRupiah(state.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D4037),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            try {
                              final authState = context.read<AuthCubit>().state;
                              String? currentUserId;
                              if (authState is AuthAuthenticated) {
                                currentUserId = authState.user.id;
                              }

                              final newTransaction = TransactionRecord(
                                id: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
                                date: DateTime.now(),
                                subtotal: state.subtotal,
                                tax: state.tax,
                                discount: state.discount,
                                total: state.total,
                                paymentAmount: state.total, // Dummy payment amount
                                change: 0.0,
                                userId: currentUserId,
                                items: state.items
                                    .map((item) => OrderItemRecord(
                                          productId: item.product.id,
                                          productName: item.product.name,
                                          price: item.unitPrice,
                                          quantity: item.quantity,
                                          imageUrl: item.product.imageUrl,
                                          toppings: item.selectedToppings,
                                          notes: item.notes,
                                        ))
                                    .toList(),
                                status: 'pending', // Set status to pending
                              );
                              
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(pendingTransaction: newTransaction),
                                  ),
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
