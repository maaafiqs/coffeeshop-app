import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/voucher_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'voucher_form_page.dart';

class VoucherManagementPage extends StatefulWidget {
  const VoucherManagementPage({super.key});

  @override
  State<VoucherManagementPage> createState() => _VoucherManagementPageState();
}

class _VoucherManagementPageState extends State<VoucherManagementPage> {
  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    final maps = await DatabaseHelper.instance.readAllVouchers();
    setState(() {
      _vouchers = maps.map((e) => VoucherModel.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteVoucher(String code) async {
    await DatabaseHelper.instance.deleteVoucher(code);
    _loadVouchers();
  }

  void _confirmDelete(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Voucher?'),
        content: Text('Voucher $code akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteVoucher(code);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Manajemen Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? const Center(child: Text('Belum ada voucher.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = _vouchers[index];
                    final discountText = voucher.discountType == 'percentage'
                        ? '${voucher.discountValue.toInt()}%'
                        : formatRupiah(voucher.discountValue);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: voucher.isActive ? Colors.green.shade100 : Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_offer,
                            color: voucher.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Diskon: $discountText', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF5D4037))),
                            Text('Min. Beli: ${formatRupiah(voucher.minPurchase)}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => VoucherFormPage(voucher: voucher)),
                                );
                                _loadVouchers();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, voucher.code),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3E2723),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VoucherFormPage()),
          );
          _loadVouchers();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
