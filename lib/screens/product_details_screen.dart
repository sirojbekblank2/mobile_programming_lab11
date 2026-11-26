
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/details_cubit.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: BlocBuilder<DetailsCubit, DetailsState>(
        builder: (context, state) {
          if (state is DetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DetailsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DetailsCubit>().load(productId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DetailsLoaded) {
            final product = state.product;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Image.network(
                  product.thumbnail,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 220,
                      child: Icon(Icons.image_not_supported, size: 60),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Rating: ${product.rating} / 5'),
                if (product.brand != null)
                  Text('Brand: ${product.brand}'),
                const SizedBox(height: 12),
                Text(
                  'Dimensions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Width: ${product.dimensions.width}\n'
                  'Height: ${product.dimensions.height}\n'
                  'Depth: ${product.dimensions.depth}',
                ),
                const SizedBox(height: 20),
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: 8,
                  children: product.tags
                      .map((tag) => Chip(label: Text(tag)))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reviews',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (product.reviews.isEmpty)
                  const Text('No reviews available.')
                else
                  ...product.reviews.map(
                    (review) => Card(
                      child: ListTile(
                        title: Text(review.reviewerName),
                        subtitle: Text(
                          '${review.comment}\n'
                          '${review.date.toLocal().toString().split(' ').first}',
                        ),
                        trailing: Text('★ ${review.rating}'),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
