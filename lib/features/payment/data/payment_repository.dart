import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/coupon_model.dart';

class PaymentFailure implements Exception {
  const PaymentFailure(this.message);
  final String message;
}

class PaymentRepository {
  PaymentRepository(this._http);
  final http.Client _http;

  // Long timeout because Render's free tier needs ~50s to wake up
  static const _timeout = Duration(seconds: 60);

  Future<String> createOrder(double amount) async {
    final data = await _post(
      '/api/payment/create-order',
      {'amount': amount, 'currency': 'INR'},
    );
    if (data['success'] != true) {
      throw PaymentFailure(
          data['message']?.toString() ?? 'Could not create the order.');
    }
    return data['order']['id'] as String;
  }

  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final data = await _post('/api/payment/verify-payment', {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
    });
    return data['success'] == true;
  }

  Future<Coupon> validateCoupon(String code, double cartTotal) async {
    final data = await _post(
      '/api/coupon/validate',
      {'code': code, 'cart_total': cartTotal},
    );
    if (data['success'] != true) {
      throw PaymentFailure(data['message']?.toString() ?? 'Invalid coupon.');
    }
    return Coupon.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await _http
          .post(
        Uri.parse('${AppConfig.baseUrl}$path'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(_timeout);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on TimeoutException {
      throw const PaymentFailure(
          'The server is taking too long to respond. Please try again.');
    } on FormatException {
      throw const PaymentFailure('Unexpected response from the server.');
    } catch (e) {
      // The real cause shows up in your debug console
      debugPrint('POST $path failed: $e');
      throw const PaymentFailure('Network error. Check your connection.');
    }
  }
}