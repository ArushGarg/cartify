import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cart/models/cart_item_model.dart';
import '../../orders/data/order_repository.dart';
import '../data/payment_repository.dart';
import '../data/razorpay_service.dart';
import '../models/coupon_model.dart';

// ── Events ──
sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => const [];
}

final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted(this.items);
  final List<CartItem> items;
  @override
  List<Object?> get props => [items];
}

final class CouponApplied extends CheckoutEvent {
  const CouponApplied(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

final class CouponRemoved extends CheckoutEvent {
  const CouponRemoved();
}

final class PayPressed extends CheckoutEvent {
  const PayPressed({
    required this.name,
    required this.email,
    required this.phone,
  });
  final String name;
  final String email;
  final String phone;
  @override
  List<Object?> get props => [name, email, phone];
}

// Fired by the Razorpay SDK callbacks
final class PaymentSucceeded extends CheckoutEvent {
  const PaymentSucceeded({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });
  final String orderId;
  final String paymentId;
  final String signature;
  @override
  List<Object?> get props => [orderId, paymentId, signature];
}

final class PaymentFailed extends CheckoutEvent {
  const PaymentFailed(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── State ──
enum CheckoutStatus {
  idle,
  applyingCoupon,
  creatingOrder,
  awaitingPayment,
  verifying,
  success,
  failure,
}

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.items = const [],
    this.coupon,
    this.couponError,
    this.errorMessage,
    this.paymentId,
    this.paidAmount,
  });

  final CheckoutStatus status;
  final List<CartItem> items;
  final Coupon? coupon;
  final String? couponError;
  final String? errorMessage;
  final String? paymentId;
  final double? paidAmount;

  double get subtotal => items.fold<double>(0, (s, i) => s + i.totalPrice);
  double get discount => coupon?.discountAmount ?? 0.0;
  double get total {
    final t = subtotal - discount;
    return t < 0 ? 0.0 : t;
  }

  bool get isBusy =>
      status == CheckoutStatus.applyingCoupon ||
          status == CheckoutStatus.creatingOrder ||
          status == CheckoutStatus.verifying;

  CheckoutState copyWith({
    CheckoutStatus? status,
    Coupon? coupon,
    bool clearCoupon = false,
    String? couponError,
    String? errorMessage,
    String? paymentId,
    double? paidAmount,
  }) =>
      CheckoutState(
        status: status ?? this.status,
        items: items,
        coupon: clearCoupon ? null : (coupon ?? this.coupon),
        couponError: couponError, // reset on every emit unless provided
        errorMessage: errorMessage, // reset on every emit unless provided
        paymentId: paymentId ?? this.paymentId,
        paidAmount: paidAmount ?? this.paidAmount,
      );

  @override
  List<Object?> get props => [
    status,
    items,
    coupon,
    couponError,
    errorMessage,
    paymentId,
    paidAmount,
  ];
}

// ── Bloc ──
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required PaymentRepository payments,
    required OrderRepository orders,
    required RazorpayService razorpay,
  })  : _payments = payments,
        _orders = orders,
        _razorpay = razorpay,
        super(const CheckoutState()) {
    on<CheckoutStarted>((e, emit) => emit(CheckoutState(items: e.items)));
    on<CouponApplied>(_onCouponApplied);
    on<CouponRemoved>((e, emit) => emit(state.copyWith(clearCoupon: true)));
    on<PayPressed>(_onPayPressed);
    on<PaymentSucceeded>(_onPaymentSucceeded);
    on<PaymentFailed>((e, emit) => emit(state.copyWith(
      status: CheckoutStatus.failure,
      errorMessage: e.message,
    )));

    // SDK callbacks -> events. All logic stays inside the Bloc.
    _razorpay.listen(
      onSuccess: (r) => add(PaymentSucceeded(
        orderId: r.orderId ?? '',
        paymentId: r.paymentId ?? '',
        signature: r.signature ?? '',
      )),
      onError: (r) => add(PaymentFailed(r.message ?? 'Payment was cancelled.')),
    );
  }

  final PaymentRepository _payments;
  final OrderRepository _orders;
  final RazorpayService _razorpay;

  Future<void> _onCouponApplied(
      CouponApplied event,
      Emitter<CheckoutState> emit,
      ) async {
    final code = event.code.trim();
    if (code.isEmpty) return;

    emit(state.copyWith(status: CheckoutStatus.applyingCoupon));
    try {
      final coupon = await _payments.validateCoupon(code, state.subtotal);
      emit(state.copyWith(status: CheckoutStatus.idle, coupon: coupon));
    } on PaymentFailure catch (f) {
      emit(state.copyWith(
        status: CheckoutStatus.idle,
        clearCoupon: true,
        couponError: f.message,
      ));
    }
  }

  Future<void> _onPayPressed(
      PayPressed event,
      Emitter<CheckoutState> emit,
      ) async {
    emit(state.copyWith(status: CheckoutStatus.creatingOrder));
    try {
      final orderId = await _payments.createOrder(state.total);
      emit(state.copyWith(status: CheckoutStatus.awaitingPayment));
      _razorpay.open(
        orderId: orderId,
        amount: state.total,
        name: event.name,
        email: event.email,
        phone: event.phone,
      );
    } on PaymentFailure catch (f) {
      emit(state.copyWith(
          status: CheckoutStatus.failure, errorMessage: f.message));
    }
  }

  Future<void> _onPaymentSucceeded(
      PaymentSucceeded event,
      Emitter<CheckoutState> emit,
      ) async {
    emit(state.copyWith(status: CheckoutStatus.verifying));
    try {
      final verified = await _payments.verifyPayment(
        orderId: event.orderId,
        paymentId: event.paymentId,
        signature: event.signature,
      );
      if (!verified) {
        emit(state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage:
          'Payment could not be verified. Payment ID: ${event.paymentId}',
        ));
        return;
      }

      await _orders.createPaidOrder(
        totalAmount: state.total,
        razorpayOrderId: event.orderId,
        razorpayPaymentId: event.paymentId,
        items: state.items,
      );

      emit(state.copyWith(
        status: CheckoutStatus.success,
        paymentId: event.paymentId,
        paidAmount: state.total,
      ));
    } on PaymentFailure catch (f) {
      emit(state.copyWith(
          status: CheckoutStatus.failure, errorMessage: f.message));
    } catch (_) {
      // Money was taken but saving the order failed -> never hide this
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage:
        'Payment received but the order could not be saved. Keep this Payment ID: ${event.paymentId}',
      ));
    }
  }

  @override
  Future<void> close() {
    _razorpay.dispose();
    return super.close();
  }
}