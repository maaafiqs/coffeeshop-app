import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../product/data/models/topping_model.dart';
import 'topping_form_page.dart';

class ToppingManagementPage extends StatefulWidget {
  const ToppingManagementPage({super.key});

  @override
  State<ToppingManagementPage> createState() => _ToppingManagementPageState();
}

class _ToppingManagementPageState extends State<ToppingManagementPage> {
  List<Topping> _toppings = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Minuman', 'Makanan'];

  @override
  void initState() {
    super.initState();
    _loadToppings();
  }

  Future<void> _loadToppings() async {
    final list = await DatabaseHelper.instance.readAllToppings();
    if (mounted) {
      setState(() {
        _toppings = list;
        _isLoading = false;
      });
    }
  }

  List<Topping> get _filteredToppings {
    if (_selectedFilter == 'Semua') return _toppings;
    return _toppings.where((t) => t.category == _selectedFilter || t.category == 'Semua').toList();
  }

  Future<void> _deleteTopping(Topping topping) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Topping', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus topping "${topping.name}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTopping(topping.id);
      _loadToppings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topping berhasil dihapus'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Kelola Topping Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: const Color(0xFF5D4037),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedFilter = filter);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF5D4037)))
                : _filteredToppings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.extension_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada topping untuk kategori $_selectedFilter',
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredToppings.length,
                        itemBuilder: (context, index) {
                          final topping = _filteredToppings[index];
                          final isDrink = topping.category == 'Minuman';
                          final isFood = topping.category == 'Makanan';
                          final badgeColor = isDrink
                              ? const Color(0xFF5D4037)
                              : isFood
                                  ? Colors.orange.shade800
                                  : Colors.blueGrey;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: badgeColor.withOpacity(0.15),
                                child: Icon(
                                  isDrink
                                      ? Icons.local_cafe
                                      : isFood
                                          ? Icons.fastfood
                                          : Icons.extension,
                                  color: badgeColor,
                                ),
                              ),
                              title: Text(
                                topping.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      topping.category,
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatRupiah(topping.price),
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF8D6E63)),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ToppingFormPage(topping: topping),
                                        ),
                                      );
                                      if (updated == true) {
                                        _loadToppings();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteTopping(topping),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ToppingFormPage()),
          );
          if (added == true) {
            _loadToppings();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Topping', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
