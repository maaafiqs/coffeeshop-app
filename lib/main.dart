import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/pos/presentation/cubit/cart_cubit.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'features/auth/presentation/pages/role_selection_page.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => ProductCubit()),
        BlocProvider(create: (context) => CartCubit()),
      ],
      child: MaterialApp(
        title: 'Maaafiqs Coffee',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5D4037),
            primary: const Color(0xFF3E2723),
            secondary: const Color(0xFF8D6E63),
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const RoleSelectionPage(),
        },
      ),
    );
  }
}
