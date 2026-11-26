
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../cubit/details_cubit.dart';
import '../data/product_api.dart';
import '../widgets/product_tile.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    context.read<SearchBloc>().add(
                          SearchCleared(),
                        );
                  },
                ),
              ),
              onSubmitted: (query) {
                context.read<SearchBloc>().add(
                      SearchSubmitted(query),
                    );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchIdle) {
                  return const Center(
                    child: Text('Search for a product.'),
                  );
                }

                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is SearchEmpty) {
                  return Center(
                    child: Text(
                      'No products found for "${state.query}".',
                    ),
                  );
                }

                if (state is SearchError) {
                  return Center(
                    child: Text(state.message),
                  );
                }

                if (state is SearchResults) {
                  return ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
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
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
