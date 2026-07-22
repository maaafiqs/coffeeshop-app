import 'package:flutter/material.dart';
import '../../../shop/presentation/pages/customer_home_page.dart';
import '../../../shop/presentation/pages/customer_main_page.dart';
import '../../../admin/presentation/pages/admin_main_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0), // Warna dasar Cream
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(Icons.coffee_rounded, size: 80, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 32),
              const Text(
                'Maaafiqs Coffee',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3E2723),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Premium Beans & Roastery',
                style: TextStyle(color: Colors.brown.shade400, fontSize: 16, letterSpacing: 0.5),
              ),
              const SizedBox(height: 48),
              _buildRoleButton(
                context,
                title: 'Belanja Sekarang',
                subtitle: 'Masuk sebagai Pelanggan',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF5D4037), // Cokelat tua
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerMainPage()),
                ),
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context,
                title: 'Manajemen Kedai',
                subtitle: 'Masuk sebagai Admin',
                icon: Icons.admin_panel_settings_outlined,
                color: const Color(0xFF8D6E63), // Cokelat muda
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminMainPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
