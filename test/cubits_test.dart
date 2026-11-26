
import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/cubit/products_cubit.dart';
import 'package:api_catalog/data/product_api.dart';
import 'package:api_catalog/models/product.dart';
import 'package:api_catalog/models/product_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProductApi extends ProductApi {
  FakeProductApi({this.shouldFail = false});

  final bool shouldFail;

  Product get fixtureProduct {
    final file = File('test/fixtures/product.json');
    final json = jsonDecode(file.readAsStringSync())
        as Map<String, dynamic>;
    return Product.fromJson(json);
  }

  @override
  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    if (shouldFail) {
      throw const ApiException('Test error');
    }

    return ProductPage(
      products: [fixtureProduct],
      total: 1,
      skip: 0,
      limit: 20,
    );
  }
}

void main() {
  group('ProductsCubit tests', () {
    blocTest<ProductsCubit, ProductsState>(
      'emits loading then loaded when API succeeds',
      build: () => ProductsCubit(FakeProductApi()),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ProductsLoaded;

        expect(state.products.length, 1);
        expect(state.total, 1);
      },
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits loading then error when API fails',
      build: () => ProductsCubit(
        FakeProductApi(shouldFail: true),
      ),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsError>(),
      ],
      verify: (cubit) {
        final state = cubit.state as ProductsError;
        expect(state.message, 'Test error');
      },
    );
  });
}
