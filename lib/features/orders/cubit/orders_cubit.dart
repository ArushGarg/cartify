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
    // keep the current list on screen while refreshing
    emit(OrdersState(status: OrdersStatus.loading, orders: state.orders));
    try {
      final orders = await _repo.fetchOrders();
      emit(OrdersState(status: OrdersStatus.success, orders: orders));
    } catch (_) {
      emit(OrdersState(
        status: OrdersStatus.failure,
        orders: state.orders,
        errorMessage: 'Could not load your orders.',
      ));
    }
  }

  void reset() => emit(const OrdersState());
}