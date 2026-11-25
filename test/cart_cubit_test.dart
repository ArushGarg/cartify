import 'package:cartify/features/cart/cubit/cart_cubit.dart';
import 'package:cartify/features/products/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// In-memory stand-in for the on-disk storage HydratedBloc normally uses
class _MemoryStorage implements Storage {
  final Map<String, dynamic> _data = {};

  @override
  dynamic read(String key) => _data[key];

  @override
  Future<void> write(String key, dynamic value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();

  @override
  Future<void> close() async {}
}

const _shoe = Product(
  id: 'p1',
  name: 'Shoe',
  description: '',
  price: 1000,
  imageUrl: '',
  category: 'Shoes',
  stock: 5,
);

const _watch = Product(
  id: 'p2',
  name: 'Watch',
  description: '',
  price: 500,
  imageUrl: '',
  category: 'Accessories',
  stock: 3,
);

void main() {
  late CartCubit cart;

  setUp(() {
    HydratedBloc.storage = _MemoryStorage();
    cart = CartCubit();
  });

  tearDown(() => cart.close());

  test('starts empty', () {
    expect(cart.state.isEmpty, isTrue);
    expect(cart.state.itemCount, 0);
    expect(cart.state.totalAmount, 0);
  });

  test('adding the same product twice increases quantity, not rows', () {
    cart
      ..add(_shoe)
      ..add(_shoe);

    expect(cart.state.items.length, 1);
    expect(cart.state.items.first.quantity, 2);
    expect(cart.state.totalAmount, 2000);
  });

  test('itemCount sums quantities across products', () {
    cart
      ..add(_shoe)
      ..add(_shoe)
      ..add(_watch);

    expect(cart.state.items.length, 2);
    expect(cart.state.itemCount, 3);
    expect(cart.state.totalAmount, 2500);
  });

  test('decrement removes the item when quantity would reach zero', () {
    cart
      ..add(_shoe)
      ..add(_shoe)
      ..decrement(_shoe.id);
    expect(cart.state.items.single.quantity, 1);

    cart.decrement(_shoe.id);
    expect(cart.state.isEmpty, isTrue);
  });

  test('remove deletes the product regardless of quantity', () {
    cart
      ..add(_shoe)
      ..add(_shoe)
      ..add(_watch)
      ..remove(_shoe.id);

    expect(cart.state.items.single.product.id, _watch.id);
  });

  test('clearCart empties the cart', () {
    cart
      ..add(_shoe)
      ..add(_watch)
      ..clearCart();

    expect(cart.state.isEmpty, isTrue);
  });

  test('cart survives an app restart (HydratedBloc)', () async {
    cart
      ..add(_shoe)
      ..add(_shoe);
    await cart.close();

    final restored = CartCubit(); // same storage, like a fresh app launch
    expect(restored.state.items.single.product.id, _shoe.id);
    expect(restored.state.items.single.quantity, 2);
    await restored.close();
  });
}