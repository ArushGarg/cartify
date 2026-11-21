import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/config/app_config.dart';

/// Thin wrapper so the Bloc never touches the SDK directly
class RazorpayService {
  RazorpayService() : _razorpay = Razorpay();
  final Razorpay _razorpay;

  void listen({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse _) {});
  }

  void open({
    required String orderId,
    required double amount,
    required String name,
    required String email,
    required String phone,
  }) {
    _razorpay.open({
      'key': AppConfig.razorpayKeyId,
      'amount': (amount * 100).round(),
      'currency': 'INR',
      'name': 'Cartify',
      'description': 'Order Payment',
      'order_id': orderId,
      'prefill': {'name': name, 'email': email, 'contact': phone},
      'theme': {'color': '#FF6B6B'},
    });
  }

  void dispose() => _razorpay.clear();
}