
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:api_catalog/models/product.dart';

void main() {
  group('Product model tests', () {
    test('parses product from JSON fixture', () {
      final file = File('test/fixtures/product.json');

      final json = jsonDecode(file.readAsStringSync())
          as Map<String, dynamic>;

      final product = Product.fromJson(json);

      expect(product.title, 'Essence Mascara Lash Princess');
      expect(product.price, isA<double>());
      expect(product.tags.length, greaterThanOrEqualTo(2));
      expect(product.reviews.length, 3);
    });

    test('handles missing brand and tags', () {
      final json = <String, dynamic>{
        'id': 1,
        'title': 'Test Product',
        'price': 10,
        'rating': 4.5,
        'thumbnail': 'https://example.com/image.jpg',
        'dimensions': {
          'width': 10,
          'height': 20,
          'depth': 30,
        },
        'reviews': [],
      };

      final product = Product.fromJson(json);

      expect(product.brand, isNull);
      expect(product.tags, isEmpty);
    });
  });
}
