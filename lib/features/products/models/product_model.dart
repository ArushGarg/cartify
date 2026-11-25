import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    description: (json['description'] as String?) ?? '',
    price: (json['price'] as num).toDouble(),
    imageUrl: (json['image_url'] as String?) ?? '',
    category: (json['category'] as String?) ?? '',
    stock: (json['stock'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'category': category,
    'stock': stock,
  };

  @override
  List<Object?> get props =>
      [id, name, description, price, imageUrl, category, stock];
}