import 'package:ecommerce_app/models/review.dart';
import 'package:ecommerce_app/services/apiservices.dart';
import 'package:ecommerce_app/services/localservice.dart';

import '../models/product.dart';
import '../models/user.dart';

class ProductRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  List<User>? _cachedUsers;

  ProductRepository(this._apiService, this._localStorageService);

  Future<List<Product>> getProducts({int start = 0, int limit = 20}) async {
    final products = await _apiService.getProducts(start: start, limit: limit);

    _cachedUsers ??= await _apiService.getUsers();

    for (var product in products) {
      final user = _cachedUsers?.firstWhere(
        (u) => u.id == product.userId,
        orElse: () => User(id: 0, name: 'Unknown', username: '', email: ''),
      );
      product.sellerName = user?.name;
      product.isFavourite = _localStorageService.isFavourite(product.id);
    }

    return products;
  }

  Future<Product> getProductById(int id) async {
    final product = await _apiService.getProductById(id);

    _cachedUsers ??= await _apiService.getUsers();

    final user = _cachedUsers?.firstWhere(
      (u) => u.id == product.userId,
      orElse: () => User(id: 0, name: 'Unknown', username: '', email: ''),
    );
    product.sellerName = user?.name;
    product.isFavourite = _localStorageService.isFavourite(product.id);

    return product;
  }

  Future<List<Comment>> getProductReviews(int productId) async {
    return await _apiService.getCommentsByPostId(productId);
  }

  Future<bool> toggleFavourite(Product product) async {
    return await _localStorageService.toggleFavourite(product);
  }

  List<Product> getFavouriteProducts() {
    return _localStorageService.getFavourites();
  }

  bool isFavourite(int productId) {
    return _localStorageService.isFavourite(productId);
  }
}
