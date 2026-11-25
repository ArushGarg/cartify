import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../products/models/product_model.dart';

class WishlistState extends Equatable {
  const WishlistState({this.items = const []});
  final List<Product> items;

  int get count => items.length;
  bool isWishlisted(String productId) => items.any((p) => p.id == productId);

  @override
  List<Object?> get props => [items];
}

class WishlistCubit extends HydratedCubit<WishlistState> {
  WishlistCubit() : super(const WishlistState());

  void toggle(Product product) {
    final exists = state.isWishlisted(product.id);
    emit(WishlistState(
      items: exists
          ? state.items.where((p) => p.id != product.id).toList()
          : [...state.items, product],
    ));
  }

  void clearWishlist() => emit(const WishlistState());

  @override
  WishlistState? fromJson(Map<String, dynamic> json) {
    try {
      final items = (json['items'] as List)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return WishlistState(items: items);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(WishlistState state) =>
      {'items': state.items.map((p) => p.toJson()).toList()};
}