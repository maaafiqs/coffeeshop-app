import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'profile_page.dart';
import 'notification_page.dart';

class CustomerSettingsPage extends StatelessWidget {
  const CustomerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isGuest = authState is AuthGuest;
    final userName = authState is AuthAuthenticated ? authState.user.name : 'Tamu';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pengaturan', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF5D4037),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
          ),
          const SizedBox(height: 32),
          if (!isGuest) _buildSettingsItem(
            icon: Icons.account_circle, 
            title: 'Profil Saya', 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            }
          ),
          if (!isGuest) _buildSettingsItem(
            icon: Icons.notifications, 
            title: 'Notifikasi', 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
            }
          ),
          _buildSettingsItem(icon: Icons.help_outline, title: 'Pusat Bantuan', onTap: () {}),
          _buildSettingsItem(
            icon: Icons.info_outline, 
            title: 'Tentang Aplikasi', 
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tentang Aplikasi', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.coffee_rounded, size: 60, color: Color(0xFF5D4037)),
                      SizedBox(height: 16),
                      Text('Versi Aplikasi: 1.1', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Dibuat oleh: Maaafiqs Dev', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup', style: TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isGuest ? const Color(0xFF5D4037) : Colors.red.shade100,
              foregroundColor: isGuest ? Colors.white : Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () {
              if (!isGuest) {
                context.read<AuthCubit>().logout();
              }
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: Icon(isGuest ? Icons.login : Icons.logout),
            label: Text(isGuest ? 'Login / Daftar' : 'Keluar', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.brown.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5D4037)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
