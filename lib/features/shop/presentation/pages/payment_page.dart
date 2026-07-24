import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class PaymentPage extends StatefulWidget {
  final TransactionRecord pendingTransaction;

  const PaymentPage({super.key, required this.pendingTransaction});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'qris'; // 'qris' or 'va'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(widget.pendingTransaction.total),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: Color(0xFF3E2723)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildMethodOption('QRIS', 'Scan menggunakan M-Banking/E-Wallet', 'qris', Icons.qr_code_2),
            const SizedBox(height: 12),
            _buildMethodOption('Virtual Account', 'Transfer melalui Bank (Simulasi)', 'va', Icons.account_balance),
            const SizedBox(height: 32),
            if (_selectedMethod == 'qris') _buildQrisSection(),
            if (_selectedMethod == 'va') _buildVaSection(),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _simulatePaymentSuccess(context),
              child: const Text('Simulasikan Pembayaran Berhasil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String title, String subtitle, String value, IconData icon) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D4037).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5D4037) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF5D4037) : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF3E2723) : Colors.black87)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF5D4037)),
          ],
        ),
      ),
    );
  }

  Widget _buildQrisSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('Scan QRIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          // Mock QR Image
          Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            child: Icon(Icons.qr_code_2, size: 150, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          const Text('Gunakan aplikasi M-Banking atau E-Wallet pilihan Anda untuk memindai kode di atas.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVaSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('Nomor Virtual Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '8077 1234 5678 9012',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 2, color: Color(0xFF3E2723)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Silakan transfer ke nomor virtual account di atas. (Ini adalah simulasi)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _simulatePaymentSuccess(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037))),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Save transaction locally
    await DatabaseHelper.instance.createTransaction(widget.pendingTransaction);
    // Calculate & award loyalty points (1 point per Rp 10.000 spent)
    int pointsEarned = (widget.pendingTransaction.total / 10000).floor();
    if (widget.pendingTransaction.userId != null && pointsEarned > 0) {
      await DatabaseHelper.instance.updateUserPoints(widget.pendingTransaction.userId!, pointsEarned);
      final updatedUser = await DatabaseHelper.instance.getUserById(widget.pendingTransaction.userId!);
      if (updatedUser != null && context.mounted) {
        context.read<AuthCubit>().loginAsUser(updatedUser);
      }
    }

    if (context.mounted) {
      Navigator.pop(context); // Close loading
      
      // Clear cart
      context.read<CartCubit>().clearCart();

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 12),
              const Text('Transaksi Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
              const SizedBox(height: 6),
              const Text('Terima kasih atas pesanan Anda. Silakan tunggu pesanan Anda disiapkan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              if (pointsEarned > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👑 ', style: TextStyle(fontSize: 16)),
                      Text(
                        '+$pointsEarned Poin Loyalitas Diperoleh!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D4037),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Close success dialog
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      );

      if (context.mounted) {
        Navigator.pop(context); // Close Payment Page (back to main page)
      }
    }
  }
}
