import 'package:flutter/material.dart';
import 'customer_home_page.dart';
import 'order_history_page.dart';
import 'cart_checkout_page.dart';
import 'customer_favorites_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'customer_settings_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../pos/presentation/cubit/cart_cubit.dart';

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CustomerHomePage(onNavigateToCart: () {
        setState(() => _currentIndex = 2);
      }),
      const CustomerFavoritesPage(),
      CartCheckoutPage(onNavigateToHome: () {
        setState(() => _currentIndex = 0);
      }),
      const OrderHistoryPage(),
      const CustomerSettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1 || index == 2 || index == 3) {
                final authState = context.read<AuthCubit>().state;
                if (authState is! AuthAuthenticated) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Akses Dibatasi', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.bold)),
                      content: Text(
                        index == 1 ? 'Silakan login untuk melihat produk favorit Anda.' : 
                        index == 2 ? 'Silakan login untuk melihat keranjang Anda.' : 
                        'Silakan login untuk melihat riwayat pesanan Anda.'
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D4037),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                          },
                          child: const Text('Login Sekarang'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
              }
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed, // Penting agar background tidak putih polos menyatu dan tulisan terlihat semua
            selectedItemColor: const Color(0xFF5D4037),
            unselectedItemColor: Colors.grey.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Favorit',
              ),
              BottomNavigationBarItem(
                icon: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    final int totalItems = state.items.fold(0, (sum, item) => sum + item.quantity);
                    if (totalItems > 0) {
                      return Badge(
                        label: Text(totalItems.toString()),
                        child: const Icon(Icons.shopping_cart_rounded),
                      );
                    }
                    return const Icon(Icons.shopping_cart_rounded);
                  },
                ),
                label: 'Keranjang',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'Riwayat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Setting',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
