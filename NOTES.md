# Mobile Programming Lab — Notes

## 1. Trace a product from the HTTP response to the product row

The product data passes through several layers:

1. **HTTP response:** `ProductApi` receives the response from DummyJSON as an HTTP response containing JSON text.
2. **JSON decoding:** `jsonDecode()` converts the JSON text into Dart objects, primarily `Map<String, dynamic>` and `List`.
3. **Model conversion:** `Product.fromJson()` converts the raw map into a strongly typed `Product` object. Nested dimensions and reviews are converted into their respective model classes.
4. **State management:** `ProductsCubit` receives the `ProductPage` and emits a `ProductsLoaded` state containing a list of `Product` objects.
5. **UI rendering:** `ProductsScreen` uses `BlocBuilder` to listen to the Cubit state and creates a `ProductTile` for each product.

The relevant files are:
- `lib/data/product_api.dart`
- `lib/models/product.dart`
- `lib/models/product_page.dart`
- `lib/models/review.dart`
- `lib/cubit/products_cubit.dart`
- `lib/screens/products_screen.dart`
- `lib/widgets/product_tile.dart`

## 2. Which errors can getProducts encounter, and which state does the user see?

Possible errors include:

- **HTTP errors:** The server returns a status code other than 200.
- **Network errors:** The device cannot establish a connection.
- **Timeout errors:** The request takes longer than 10 seconds.
- **Invalid JSON:** The server returns data that cannot be decoded.
- **Unexpected errors:** Other exceptions occur during the request or parsing process.

The API service converts these failures into `ApiException` objects.

`ProductsCubit` catches these exceptions and emits `ProductsError`, which the UI displays with an error message and a Retry button.

## 3. When should you use Cubit versus Bloc?

Cubit is suitable when state changes can be triggered directly through simple methods.

For example, `ProductsCubit` exposes methods such as `load()` and `loadMore()`. The UI calls these methods to load or paginate products.

Bloc is more suitable when an application has distinct events that need to be processed with specific behavior.

For example, `SearchBloc` handles `SearchSubmitted` and `SearchCleared` events. It also uses the `restartable()` transformer to handle rapidly changing search requests.

In short:
- **Cubit:** Simple method-based state management.
- **Bloc:** Event-based state management with more control over event processing.

## 4. What does restartable() do?

`restartable()` ensures that when a new event of the same registered event type arrives, the previous event handler is cancelled.

In the search screen, if the user searches for "phone" and then quickly searches for "laptop", the previous search handler is cancelled and the newer search takes priority.

Without `restartable()`, both requests could finish in an unexpected order, potentially allowing older results to overwrite newer results.

Note that cancelling the event handler does not necessarily terminate the underlying HTTP request.

## 5. Why should widgets not call http.get() or read raw Maps directly?

There are two main reasons:

1. **Separation of concerns:** Widgets should focus on displaying UI, not handling networking, JSON parsing, or business logic. Keeping API calls in the service layer makes the application easier to maintain and test.

2. **Type safety and testability:** Models provide strongly typed objects instead of raw maps. Cubit and Bloc manage application state independently of the UI, allowing them to be tested without making real network requests.

This architecture makes the application more organized, maintainable, and reliable.