import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../product/data/models/topping_model.dart';

class ToppingFormPage extends StatefulWidget {
  final Topping? topping;
  const ToppingFormPage({super.key, this.topping});

  @override
  State<ToppingFormPage> createState() => _ToppingFormPageState();
}

class _ToppingFormPageState extends State<ToppingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String _selectedCategory = 'Minuman';

  final List<String> _categories = ['Minuman', 'Makanan', 'Semua'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topping?.name ?? '');
    _priceController = TextEditingController(
      text: widget.topping != null ? widget.topping!.price.toInt().toString() : '',
    );
    if (widget.topping != null && _categories.contains(widget.topping!.category)) {
      _selectedCategory = widget.topping!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveTopping() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      final topping = Topping(
        id: widget.topping?.id ?? 'top_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        price: price,
        category: _selectedCategory,
      );

      if (widget.topping == null) {
        await DatabaseHelper.instance.createTopping(topping);
      } else {
        await DatabaseHelper.instance.updateTopping(topping);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.topping == null ? 'Topping berhasil ditambahkan!' : 'Topping diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.topping != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Topping' : 'Tambah Topping Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Topping',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Topping / Ekstra',
                        hintText: 'Contoh: Extra Shot Espresso, Extra Keju',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.extension, color: Color(0xFF5D4037)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama topping tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)',
                        hintText: 'Contoh: 5000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.payments, color: Color(0xFF5D4037)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori Target Produk',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.category, color: Color(0xFF5D4037)),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat == 'Semua' ? 'Semua Produk (Makanan & Minuman)' : 'Khusus $cat',
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D4037),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saveTopping,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Topping',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
