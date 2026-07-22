import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/cubit/product_cubit.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product; // Jika null, berarti Mode Tambah. Jika ada, Mode Edit.

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  String _category = 'Coffee';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toInt().toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? 'https://images.unsplash.com/photo-1559525839-b184a4d698c7?q=80&w=600&auto=format&fit=crop');
    if (widget.product != null) {
      _category = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id: widget.product?.id ?? 'CFF-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descController.text,
        category: _category,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageUrl: _imageUrlController.text,
      );

      if (widget.product == null) {
        context.read<ProductCubit>().addProduct(newProduct);
      } else {
        context.read<ProductCubit>().updateProduct(newProduct);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Nama Kopi', _nameController, icon: Icons.coffee),
              const SizedBox(height: 16),
              _buildTextField('Deskripsi', _descController, icon: Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: ['Coffee', 'Non-Coffee', 'Frappe', 'Tea', 'Snack']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildTextField('Harga (Rp)', _priceController, icon: Icons.attach_money, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Stok', _stockController, icon: Icons.inventory, isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('URL Gambar', _imageUrlController, icon: Icons.image),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E2723),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveForm,
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah ke Menu', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Wajib diisi';
        if (isNumber && double.tryParse(value) == null) return 'Harus berupa angka';
        return null;
      },
    );
  }
}
