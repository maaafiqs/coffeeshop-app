import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Notifikasi Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard('Stok Hampir Habis', 'Stok Kopi Susu Aren tersisa 5 cup.', Icons.warning, Colors.orange),
          _buildNotificationCard('Pesanan Baru', 'Terdapat 3 pesanan baru yang menunggu diproses.', Icons.shopping_cart, Colors.blue),
          _buildNotificationCard('Laporan Mingguan', 'Laporan pendapatan minggu ini sudah tersedia.', Icons.analytics, Colors.green),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String title, String message, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message, style: const TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
