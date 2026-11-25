import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../products/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartState extends Equatable {
  const CartState({this.items = const []});
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold<int>(0, (sum, i) => sum + i.quantity);
  double get totalAmount =>
      items.fold<double>(0, (sum, i) => sum + i.totalPrice);

  @override
  List<Object?> get props => [items];
}

/// HydratedCubit = state is saved to disk automatically and restored on launch.
/// Note: HydratedMixin already defines clear() (deletes the saved copy),
/// so our own "empty the cart" method is called clearCart().
class CartCubit extends HydratedCubit<CartState> {
  CartCubit() : super(const CartState());

  void add(Product product) {
    final items = [...state.items];
    final i = items.indexWhere((e) => e.product.id == product.id);
    if (i >= 0) {
      items[i] = items[i].copyWith(quantity: items[i].quantity + 1);
    } else {
      items.add(CartItem(product: product));
    }
    emit(CartState(items: items));
  }

  void remove(String productId) => emit(CartState(
    items: state.items.where((e) => e.product.id != productId).toList(),
  ));

  void increment(String productId) => emit(CartState(
    items: [
      for (final e in state.items)
        e.product.id == productId
            ? e.copyWith(quantity: e.quantity + 1)
            : e,
    ],
  ));

  void decrement(String productId) {
    final updated = <CartItem>[];
    for (final e in state.items) {
      if (e.product.id != productId) {
        updated.add(e);
      } else if (e.quantity > 1) {
        updated.add(e.copyWith(quantity: e.quantity - 1));
      } // quantity would hit 0 -> drop the item
    }
    emit(CartState(items: updated));
  }

  void clearCart() => emit(const CartState());

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final items = (json['items'] as List)
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return CartState(items: items);
    } catch (_) {
      return null; // corrupted cache -> start with an empty cart
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) =>
      {'items': state.items.map((e) => e.toJson()).toList()};
}