import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/database/database_helper.dart';
import 'package:file_picker/file_picker.dart';
import '../pages/admin_main_page.dart';
import '../../../product/presentation/cubit/product_cubit.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom harus diisi', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      
      // Verifikasi password lama
      if (user.password != oldPassword) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password lama salah', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        return;
      }

      // Update password
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: newPassword,
        role: user.role,
      );
      await DatabaseHelper.instance.updateUser(updatedUser);
      
      // Update state di AuthCubit
      if (mounted) {
        context.read<AuthCubit>().loginAsUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    }
  }

  void _backupDatabase() async {
    try {
      final String? selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Pilih Folder untuk Menyimpan Backup',
      );
      if (selectedDirectory != null) {
        final destPath = '$selectedDirectory/coffeeshop_backup.db';
        await DatabaseHelper.instance.backupDatabase(destPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database berhasil di-backup ke:\n$destPath'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal backup: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _restoreDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final String sourcePath = result.files.single.path!;
        
        if (!mounted) return;
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Restore'),
            content: const Text('Apakah Anda yakin ingin me-restore database? Semua data saat ini akan ditimpa.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore', style: TextStyle(color: Colors.red))),
            ],
          ),
        );

        if (confirm == true) {
          await DatabaseHelper.instance.restoreDatabase(sourcePath);
          if (mounted) {
            context.read<ProductCubit>().fetchProducts();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database berhasil di-restore.'), backgroundColor: Colors.green));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminMainPage()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal restore: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Keamanan Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Color(0xFF5D4037)),
            const SizedBox(height: 24),
            const Text('Ubah Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _buildPasswordField('Password Lama', _oldPasswordController, _obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
            const SizedBox(height: 16),
            _buildPasswordField('Password Baru', _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            const SizedBox(height: 16),
            _buildPasswordField('Konfirmasi Password Baru', _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _changePassword,
              child: const Text('Simpan Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 24),
            const Text('Backup & Restore Database', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Amankan data Anda dengan melakukan backup secara berkala.', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5D4037),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF5D4037))),
                    ),
                    onPressed: _backupDatabase,
                    icon: const Icon(Icons.download),
                    label: const Text('Backup'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5D4037),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF5D4037))),
                    ),
                    onPressed: _restoreDatabase,
                    icon: const Icon(Icons.upload),
                    label: const Text('Restore'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF5D4037)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
