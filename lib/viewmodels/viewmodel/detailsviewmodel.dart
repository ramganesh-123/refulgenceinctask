import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/models/review.dart';
import 'package:ecommerce_app/services/dependanct.dart';
import 'package:ecommerce_app/services/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailState {
  final Product? product;
  final List<Comment> reviews;
  final bool isLoading;
  final String? error;

  ProductDetailState({
    this.product,
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  ProductDetailState copyWith({
    Product? product,
    List<Comment>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProductDetailViewModel extends StateNotifier<ProductDetailState> {
  final ProductRepository _repository;

  ProductDetailViewModel(this._repository) : super(ProductDetailState());

  Future<void> loadProductDetails(int productId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final product = await _repository.getProductById(productId);
      final reviews = await _repository.getProductReviews(productId);

      state = state.copyWith(
        product: product,
        reviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFavourite() async {
    if (state.product == null) return;

    final isFav = await _repository.toggleFavourite(state.product!);
    state = state.copyWith(
      product: state.product!.copyWith(isFavourite: isFav),
    );
  }

  void addLocalReview(String name, String email, String body) {
    if (state.product == null) return;

    final newReview = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      postId: state.product!.id,
      name: name,
      email: email,
      body: body,
    );

    state = state.copyWith(
      reviews: [newReview, ...state.reviews],
    );
  }
}

final productDetailViewModelProvider = StateNotifierProvider.family<
    ProductDetailViewModel, ProductDetailState, int>(
  (ref, productId) {
    final viewModel = ProductDetailViewModel(getIt<ProductRepository>());
    viewModel.loadProductDetails(productId);
    return viewModel;
  },
);
