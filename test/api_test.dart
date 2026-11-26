
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:api_catalog/data/product_api.dart';

void main() {
  group('ProductApi tests', () {
    test('getProducts returns one product', () async {
      final fixture = File('test/fixtures/product.json');
      final productJson = jsonDecode(
        fixture.readAsStringSync(),
      ) as Map<String, dynamic>;

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'products': [productJson],
            'total': 1,
            'skip': 0,
            'limit': 20,
          }),
          200,
        );
      });

      final api = ProductApi(client: client);

      final page = await api.getProducts();

      expect(page.products.length, 1);
      expect(
        page.products.first.title,
        'Essence Mascara Lash Princess',
      );

      api.dispose();
    });

    test('getProduct throws ApiException on 404', () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"message":"Product not found"}',
          404,
        );
      });

      final api = ProductApi(client: client);

      expect(
        () => api.getProduct(999),
        throwsA(isA<ApiException>()),
      );

      api.dispose();
    });
  });
}
