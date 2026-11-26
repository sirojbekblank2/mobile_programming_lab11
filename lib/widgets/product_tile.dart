
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Image.network(
          product.thumbnail,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              width: 65,
              height: 65,
              child: Icon(Icons.image_not_supported),
            );
          },
        ),
        title: Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '\$${product.price.toStringAsFixed(2)}'
            '  •  ★ ${product.rating.toStringAsFixed(1)}',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
