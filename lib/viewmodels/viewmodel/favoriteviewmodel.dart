import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/services/dependanct.dart';
import 'package:ecommerce_app/services/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavouritesState {
  final List<Product> favourites;
  final bool isLoading;

  FavouritesState({
    this.favourites = const [],
    this.isLoading = false,
  });

  FavouritesState copyWith({
    List<Product>? favourites,
    bool? isLoading,
  }) {
    return FavouritesState(
      favourites: favourites ?? this.favourites,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavouritesViewModel extends StateNotifier<FavouritesState> {
  final ProductRepository _repository;

  FavouritesViewModel(this._repository) : super(FavouritesState());

  void loadFavourites() {
    state = state.copyWith(isLoading: true);
    final favourites = _repository.getFavouriteProducts();
    state = state.copyWith(
      favourites: favourites,
      isLoading: false,
    );
  }

  Future<void> removeFavourite(Product product) async {
    await _repository.toggleFavourite(product);
    loadFavourites();
  }
}

final favouritesViewModelProvider =
    StateNotifierProvider<FavouritesViewModel, FavouritesState>(
  (ref) => FavouritesViewModel(getIt<ProductRepository>()),
);
