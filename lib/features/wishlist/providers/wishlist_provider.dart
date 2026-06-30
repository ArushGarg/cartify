import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;
  int get count => _items.length;

  bool isWishlisted(String productId) {
    return _items.any((p) => p.id == productId);
  }

  void toggleWishlist(Product product) {
    if (isWishlisted(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }
}