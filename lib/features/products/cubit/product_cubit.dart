import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/product_repository.dart';
import '../models/product_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.selectedCategory = 'All',
    this.errorMessage,
  });

  final ProductStatus status;
  final List<Product> products;
  final String selectedCategory;
  final String? errorMessage;

  List<Product> get visible => selectedCategory == 'All'
      ? products
      : products.where((p) => p.category == selectedCategory).toList();

  List<String> get categories =>
      ['All', ...{...products.map((p) => p.category)}];

  List<Product> get featured => products.take(5).toList();

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    String? selectedCategory,
    String? errorMessage,
  }) =>
      ProductState(
        status: status ?? this.status,
        products: products ?? this.products,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        errorMessage: errorMessage, // intentionally not preserved
      );

  @override
  List<Object?> get props => [status, products, selectedCategory, errorMessage];
}

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._repo) : super(const ProductState());
  final ProductRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await _repo.fetchProducts();
      emit(state.copyWith(status: ProductStatus.success, products: products));
    } catch (_) {
      emit(state.copyWith(
        status: ProductStatus.failure,
        errorMessage: 'Failed to load products. Check your connection.',
      ));
    }
  }

  void selectCategory(String category) =>
      emit(state.copyWith(selectedCategory: category));
}