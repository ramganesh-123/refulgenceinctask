import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class LocalStorageService {
  final SharedPreferences _prefs;
  static const String _favouritesKey = 'favourite_products';

  LocalStorageService(this._prefs);

  Future<void> saveFavourites(List<Product> products) async {
    final jsonList = products.map((p) => p.toJson()).toList();
    await _prefs.setString(_favouritesKey, jsonEncode(jsonList));
    print('Saved ${products.length} favourites');
  }

  List<Product> getFavourites() {
    final jsonString = _prefs.getString(_favouritesKey);
    if (jsonString == null) {
      print('No favourites found');
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    final favourites = jsonList.map((json) => Product.fromJson(json)).toList();
    print('Loaded ${favourites.length} favourites');
    return favourites;
  }

  Future<void> addFavourite(Product product) async {
    final favourites = getFavourites();
    if (!favourites.any((p) => p.id == product.id)) {
      favourites.add(product.copyWith(isFavourite: true));
      await saveFavourites(favourites);
      print('Added product ${product.id} to favourites');
    }
  }

  Future<void> removeFavourite(int productId) async {
    final favourites = getFavourites();
    favourites.removeWhere((p) => p.id == productId);
    await saveFavourites(favourites);
    print('Removed product $productId from favourites');
  }

  bool isFavourite(int productId) {
    final favourites = getFavourites();
    final isFav = favourites.any((p) => p.id == productId);
    print('Product $productId is favourite: $isFav');
    return isFav;
  }

  Future<bool> toggleFavourite(Product product) async {
    if (isFavourite(product.id)) {
      await removeFavourite(product.id);
      return false;
    } else {
      await addFavourite(product);
      return true;
    }
  }
}
