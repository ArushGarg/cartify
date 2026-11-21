import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/order_repository.dart';
import '../models/order_model.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  final OrdersStatus status;
  final List<OrderModel> orders;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, orders, errorMessage];
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(const OrdersState());
  final OrderRepository _repo;

  Future<void> load() async {
    emit(const OrdersState(status: OrdersStatus.loading));
    try {
      final orders = await _repo.fetchOrders();
      emit(OrdersState(status: OrdersStatus.success, orders: orders));
    } catch (_) {
      emit(const OrdersState(
        status: OrdersStatus.failure,
        errorMessage: 'Could not load your orders.',
      ));
    }
  }
}