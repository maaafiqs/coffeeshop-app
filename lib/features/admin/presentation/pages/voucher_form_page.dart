import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/voucher_model.dart';

class VoucherFormPage extends StatefulWidget {
  final VoucherModel? voucher;

  const VoucherFormPage({super.key, this.voucher});

  @override
  State<VoucherFormPage> createState() => _VoucherFormPageState();
}

class _VoucherFormPageState extends State<VoucherFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _codeController;
  late TextEditingController _discountValueController;
  late TextEditingController _minPurchaseController;
  
  String _discountType = 'nominal';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.voucher?.code ?? '');
    _discountValueController = TextEditingController(text: widget.voucher?.discountValue.toString() ?? '');
    _minPurchaseController = TextEditingController(text: widget.voucher?.minPurchase.toString() ?? '');
    
    if (widget.voucher != null) {
      _discountType = widget.voucher!.discountType;
      _isActive = widget.voucher!.isActive;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  Future<void> _saveVoucher() async {
    if (_formKey.currentState!.validate()) {
      final newVoucher = VoucherModel(
        code: _codeController.text.toUpperCase(),
        discountType: _discountType,
        discountValue: double.tryParse(_discountValueController.text) ?? 0,
        minPurchase: double.tryParse(_minPurchaseController.text) ?? 0,
        isActive: _isActive,
      );

      if (widget.voucher == null) {
        // Cek apakah kode sudah ada
        final existing = await DatabaseHelper.instance.readVoucher(newVoucher.code);
        if (existing != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kode voucher sudah digunakan!'), backgroundColor: Colors.red),
            );
          }
          return;
        }
        await DatabaseHelper.instance.createVoucher(newVoucher.toMap());
      } else {
        await DatabaseHelper.instance.updateVoucher(newVoucher.toMap());
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Voucher' : 'Tambah Voucher'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Kode Voucher (contoh: HEMAT10)'),
              enabled: !isEdit, // Kode tidak bisa diubah jika edit
              textCapitalization: TextCapitalization.characters,
              validator: (val) => val == null || val.isEmpty ? 'Kode wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _discountType,
              decoration: const InputDecoration(labelText: 'Tipe Diskon'),
              items: const [
                DropdownMenuItem(value: 'nominal', child: Text('Nominal (Rp)')),
                DropdownMenuItem(value: 'percentage', child: Text('Persentase (%)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _discountType = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountValueController,
              decoration: InputDecoration(
                labelText: _discountType == 'percentage' ? 'Besaran Persentase (%)' : 'Potongan Harga (Rp)',
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Wajib diisi';
                final v = double.tryParse(val);
                if (v == null) return 'Harus berupa angka';
                if (_discountType == 'percentage' && (v <= 0 || v > 100)) return 'Persentase harus 1-100';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minPurchaseController,
              decoration: const InputDecoration(labelText: 'Minimal Pembelian (Rp)'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Wajib diisi';
                if (double.tryParse(val) == null) return 'Harus berupa angka';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Status Aktif'),
              value: _isActive,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2723),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveVoucher,
              child: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
