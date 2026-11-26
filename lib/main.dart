
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/product_api.dart';
import 'cubit/products_cubit.dart';
import 'screens/products_screen.dart';

void main() {
  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ProductApi(),
      dispose: (api) => api.dispose(),
      child: BlocProvider(
        create: (context) => ProductsCubit(
          context.read<ProductApi>(),
        )..load(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Product Catalogue',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
            ),
            useMaterial3: true,
          ),
          home: const ProductsScreen(),
        ),
      ),
    );
  }
}
