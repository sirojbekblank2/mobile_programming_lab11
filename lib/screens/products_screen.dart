
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../cubit/details_cubit.dart';
import '../bloc/search_bloc.dart';
import '../data/product_api.dart';
import '../widgets/product_tile.dart';
import 'product_details_screen.dart';
import 'search_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalogue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search products',
            onPressed: () {
              final api = context.read<ProductApi>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => SearchBloc(api),
                    child: const SearchScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProductsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductsCubit>().load();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductsLoaded) {
            return RefreshIndicator(
              onRefresh: () {
                return context.read<ProductsCubit>().load();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.products.length +
                    (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.products.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: state.isLoadingMore
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<ProductsCubit>()
                                      .loadMore();
                                },
                                child: const Text('Load more'),
                              ),
                      ),
                    );
                  }

                  final product = state.products[index];

                  return ProductTile(
                    product: product,
                    onTap: () {
                      final api = context.read<ProductApi>();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => DetailsCubit(api)
                              ..load(product.id),
                            child: ProductDetailsScreen(
                              productId: product.id,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
