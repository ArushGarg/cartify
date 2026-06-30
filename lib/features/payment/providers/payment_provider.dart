import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PaymentProvider extends ChangeNotifier {
  late Razorpay _razorpay;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Replace with your local IP when testing on emulator
  // For emulator use: http://10.0.2.2:3000
  static const String baseUrl = 'https://cartify-backend-xfir.onrender.com';

  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;

  void initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) onSuccess!(response);
  }

  void _handleFailure(PaymentFailureResponse response) {
    if (onFailure != null) onFailure!(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }

  Future<String?> createOrder(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': 'INR',
        }),
      ).timeout(const Duration(seconds: 60)); // add this

      final data = jsonDecode(response.body);
      if (data['success']) {
        _isLoading = false;
        notifyListeners();
        return data['order']['id'];
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        }),
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      return false;
    }
  }

  void openPaymentSheet({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) {
    var options = {
      'key': 'rzp_test_T79hR4fYcrUflr', // replace with your key
      'amount': (amount * 100).toInt(),
      'currency': 'INR',
      'name': 'Cartify',
      'description': 'Order Payment',
      'order_id': orderId,
      'prefill': {
        'name': customerName,
        'email': customerEmail,
        'contact': customerPhone,
      },
      'theme': {'color': '#6C63FF'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay error: $e');
    }
  }
}