
import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/bloc/search_bloc.dart';
import 'package:api_catalog/bloc/search_event.dart';
import 'package:api_catalog/bloc/search_state.dart';
import 'package:api_catalog/data/product_api.dart';
import 'package:api_catalog/models/product_page.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSearchApi extends ProductApi {
  FakeSearchApi({this.shouldReturnEmpty = false});

  final bool shouldReturnEmpty;

  @override
  Future<ProductPage> search(String query) async {
    if (shouldReturnEmpty) {
      return const ProductPage(
        products: [],
        total: 0,
        skip: 0,
        limit: 20,
      );
    }

    final file = File('test/fixtures/product.json');

    final json = jsonDecode(file.readAsStringSync())
        as Map<String, dynamic>;

    return ProductPage(
      products: [
        ProductPage.fromJson({
          'products': [json],
          'total': 1,
          'skip': 0,
          'limit': 20,
        }).products.first,
      ],
      total: 1,
      skip: 0,
      limit: 20,
    );
  }
}

void main() {
  group('SearchBloc tests', () {
    blocTest<SearchBloc, SearchState>(
      'emits loading then results for a valid search',
      build: () => SearchBloc(FakeSearchApi()),
      act: (bloc) {
        bloc.add(SearchSubmitted('phone'));
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchResults>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SearchResults;
        expect(state.products.length, 1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits idle for an empty search',
      build: () => SearchBloc(FakeSearchApi()),
      act: (bloc) {
        bloc.add(SearchSubmitted('   '));
      },
      expect: () => [
        isA<SearchIdle>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits empty when the API returns no products',
      build: () => SearchBloc(
        FakeSearchApi(shouldReturnEmpty: true),
      ),
      act: (bloc) {
        bloc.add(SearchSubmitted('unknown product'));
      },
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>(),
      ],
    );
  });
}
