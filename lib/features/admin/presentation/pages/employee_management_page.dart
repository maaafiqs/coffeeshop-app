import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/pages/register_page.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  List<UserModel> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final employees = await DatabaseHelper.instance.readAllUsersByRole('admin');
    if (mounted) {
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Kelola Karyawan & Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
      ),
      body: _employees.isEmpty
          ? const Center(child: Text('Belum ada karyawan', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final emp = _employees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF5D4037).withOpacity(0.1),
                      child: const Icon(Icons.person, color: Color(0xFF5D4037)),
                    ),
                    title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(emp.email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(emp.role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                        ),
                        if (emp.id != 'admin-default') ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _confirmDelete(context, emp),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Admin'),
        onPressed: () async {
          // Navigasi ke halaman register namun mungkin perlu modifikasi
          // Di sini kita bisa membuat halaman register khusus atau memanggil dialog
          // Untuk simpelnya, kita gunakan RegisterPage yang sudah ada, namun itu akan mendaftar sebagai customer.
          // Mari kita buat form cepat disini untuk tambah admin.
          _showAddAdminDialog(context);
        },
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Admin Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final password = passwordController.text;

              if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                final newUser = UserModel(
                  id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  email: email,
                  password: password,
                  role: 'admin',
                );

                await DatabaseHelper.instance.registerUser(newUser);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin berhasil ditambahkan!'), backgroundColor: Colors.green));
                  _loadEmployees();
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Admin?'),
        content: Text('Apakah Anda yakin ingin menghapus admin "${emp.name}"?\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteUser(emp.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin berhasil dihapus'), backgroundColor: Colors.green));
                _loadEmployees();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
