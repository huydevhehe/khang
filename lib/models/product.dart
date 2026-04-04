import '../services/api_service.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://picsum.photos/200',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  String get fullImageUrl {
    if (imageUrl.isEmpty) {
      return 'https://picsum.photos/200';
    }
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    // Prepend dynamic baseUrl for local uploads
    // ApiService.baseUrl is http://10.0.2.2:8080/api
    return '${ApiService.baseUrl.replaceFirst('/api', '')}/uploads/$imageUrl';
  }
}
