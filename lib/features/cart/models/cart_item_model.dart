import 'package:equatable/equatable.dart';
import '../../products/models/product_model.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  double get totalPrice => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  Map<String, dynamic> toJson() =>
      {'product': product.toJson(), 'quantity': quantity};

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product:
    Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
    quantity: json['quantity'] as int,
  );

  @override
  List<Object?> get props => [product, quantity];
}