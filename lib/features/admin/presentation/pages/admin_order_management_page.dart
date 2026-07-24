import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../../../../core/utils/currency_formatter.dart';

class AdminOrderManagementPage extends StatefulWidget {
  const AdminOrderManagementPage({super.key});

  @override
  State<AdminOrderManagementPage> createState() => _AdminOrderManagementPageState();
}

class _AdminOrderManagementPageState extends State<AdminOrderManagementPage> {
  List<TransactionRecord> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final tx = await DatabaseHelper.instance.readAllTransactions();
    if (mounted) {
      setState(() {
        _transactions = tx;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'transactions',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
    await FirestoreService.instance.updateTransactionStatus(id, newStatus);
    _loadTransactions();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        title: const Text('Kelola Pesanan', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
          : _transactions.isEmpty
              ? const Center(child: Text('Belum ada pesanan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    return _buildOrderCard(tx);
                  },
                ),
    );
  }

  Widget _buildOrderCard(TransactionRecord tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tx.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusBadge(tx.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(_formatDate(tx.date), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Divider(height: 20),
          if (tx.items.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tx.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D4037))),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            if (item.toppings.isNotEmpty) ...[
                              Text(
                                '+ ${item.toppingsText}',
                                style: const TextStyle(color: Color(0xFF8D6E63), fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                            if (item.notes.isNotEmpty) ...[
                              Text(
                                'Catatan: "${item.notes}"',
                                style: TextStyle(color: Colors.brown.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(formatRupiah(item.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 20),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${tx.items.fold<int>(0, (sum, i) => sum + i.quantity)} Items', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(formatRupiah(tx.total), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5D4037))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Ubah Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusButton('pending', 'Menunggu', tx),
                const SizedBox(width: 8),
                _statusButton('preparing', 'Disiapkan', tx),
                const SizedBox(width: 8),
                _statusButton('ready', 'Siap Diambil', tx),
                const SizedBox(width: 8),
                _statusButton('completed', 'Selesai', tx),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statusButton(String status, String label, TransactionRecord tx) {
    final isSelected = tx.status == status;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          _updateStatus(tx.id, status);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D4037) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case 'preparing':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        break;
      case 'ready':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade800;
        break;
      case 'completed':
      default:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
