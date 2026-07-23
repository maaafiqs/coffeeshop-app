import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/banner_model.dart';

class BannerManagementPage extends StatefulWidget {
  const BannerManagementPage({super.key});

  @override
  State<BannerManagementPage> createState() => _BannerManagementPageState();
}

class _BannerManagementPageState extends State<BannerManagementPage> {
  List<BannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final banners = await DatabaseHelper.instance.readAllBanners();
    if (mounted) {
      setState(() {
        _banners = banners;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Kelola Banner Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: _banners.isEmpty
          ? const Center(child: Text('Belum ada banner promo/info', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(banner.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteBanner(banner.id);
                        _loadBanners();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Info'),
        onPressed: () => _showAddBannerDialog(context),
      ),
    );
  }

  void _showAddBannerDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final imageController = TextEditingController(); // Optional

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Info/Promo Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Utama (Cth: Promo Spesial)'),
              ),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'Subjudul/Deskripsi Singkat'),
                maxLines: 2,
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'URL Gambar (Opsional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
            onPressed: () async {
              final title = titleController.text.trim();
              final subtitle = subtitleController.text.trim();
              final imageUrl = imageController.text.trim();

              if (title.isNotEmpty && subtitle.isNotEmpty) {
                final newBanner = BannerModel(
                  id: 'BNR-${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  subtitle: subtitle,
                  imageUrl: imageUrl.isEmpty ? 'default' : imageUrl,
                );

                await DatabaseHelper.instance.createBanner(newBanner);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner berhasil ditambahkan!'), backgroundColor: Colors.green));
                  _loadBanners();
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
