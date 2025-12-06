import 'package:dio/dio.dart';
import 'package:ecommerce_app/models/review.dart';
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  ApiService(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<List<Product>> getProducts({int start = 0, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          '_start': start,
          '_limit': limit,
        },
      );
      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get('/posts/$id');
      return Product.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Comment>> getCommentsByPostId(int postId) async {
    try {
      final response = await _dio.get(
        '/comments',
        queryParameters: {'postId': postId},
      );
      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please try again.';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return 'An unexpected error occurred';
  }
}
