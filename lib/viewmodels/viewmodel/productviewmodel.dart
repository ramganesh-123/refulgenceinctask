import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/services/dependanct.dart';
import 'package:ecommerce_app/services/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ProductListViewModel extends StateNotifier<ProductListState> {
  final ProductRepository _repository;
  String _searchQuery = '';
  String _sortBy = 'none';

  ProductListViewModel(this._repository) : super(ProductListState());

  Future<void> loadProducts({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = ProductListState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final products = await _repository.getProducts(
        start: refresh ? 0 : state.currentPage * 20,
        limit: 20,
      );

      if (products.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final updatedProducts =
          refresh ? products : [...state.products, ...products];

      state = state.copyWith(
        products: _applyFiltersAndSort(updatedProducts),
        isLoading: false,
        currentPage: refresh ? 1 : state.currentPage + 1,
        hasMore: products.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadProducts();
  }

  Future<void> toggleFavourite(Product product) async {
    final isFav = await _repository.toggleFavourite(product);

    final updatedProducts = state.products.map((p) {
      if (p.id == product.id) {
        return p.copyWith(isFavourite: isFav);
      }
      return p;
    }).toList();

    state = state.copyWith(products: updatedProducts);
  }

  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    state = state.copyWith(
      products: _applyFiltersAndSort(state.products),
    );
  }

  // Sort products
  void sortProducts(String sortBy) {
    _sortBy = sortBy;
    state = state.copyWith(
      products: _applyFiltersAndSort(state.products),
    );
  }

  List<Product> _applyFiltersAndSort(List<Product> products) {
    var filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(_searchQuery) ||
            p.body.toLowerCase().contains(_searchQuery) ||
            (p.sellerName?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    if (_sortBy == 'seller') {
      filtered
          .sort((a, b) => (a.sellerName ?? '').compareTo(b.sellerName ?? ''));
    } else if (_sortBy == 'title') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    }

    return filtered;
  }
}

final productListViewModelProvider =
    StateNotifierProvider<ProductListViewModel, ProductListState>(
  (ref) => ProductListViewModel(getIt<ProductRepository>()),
);
