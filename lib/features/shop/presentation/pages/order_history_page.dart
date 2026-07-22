import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<TransactionRecord> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final tx = await DatabaseHelper.instance.readAllTransactions();
    setState(() {
      _transactions = tx;
      _isLoading = false;
    });
  }

  Future<void> _fetchTransactions() async {
    final tx = await DatabaseHelper.instance.readAllTransactions();
    setState(() {
      _transactions = tx;
    });
  }

  Widget _buildTransactionCard(TransactionRecord tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                '${tx.date.day}/${tx.date.month}/${tx.date.year}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(fontSize: 14)),
              Text(formatRupiah(tx.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5D4037))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        title: const Text('Riwayat Pemesanan', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchTransactions();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: const Color(0xFF5D4037),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
            : _transactions.isEmpty
                ? Stack(
                    children: [
                      ListView(),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('Belum ada riwayat pesanan', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final trx = _transactions[index];
                      return _buildTransactionCard(trx);
                    },
                  ),
      ),
    );
  }
}
