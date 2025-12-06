class Product {
  final int id;
  final int userId;
  final String title;
  final String body;

  String? sellerName;
  bool isFavourite;

  Product({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.sellerName,
    this.isFavourite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      sellerName: json['sellerName'] as String?,
      isFavourite: json['isFavourite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'sellerName': sellerName,
      'isFavourite': isFavourite,
    };
  }

  Product copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    String? sellerName,
    bool? isFavourite,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      sellerName: sellerName ?? this.sellerName,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }

  String get imageUrl => 'https://picsum.photos/seed/$id/400/300';
}
