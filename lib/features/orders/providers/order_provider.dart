import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<OrderModel> _orders = [];

  bool get isLoading => _isLoading;
  List<OrderModel> get orders => _orders;

  Future<String?> createOrder({
    required double totalAmount,
    required String razorpayOrderId,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final orderResponse = await _supabase
          .from('orders')
          .insert({
        'total_amount': totalAmount,
        'razorpay_order_id': razorpayOrderId,
        'status': 'pending',
      })
          .select()
          .single();

      final orderId = orderResponse['id'];

      final orderItems = items.map((item) => {
        'order_id': orderId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      _isLoading = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      debugPrint('Error creating order: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required String paymentId,
  }) async {
    await _supabase.from('orders').update({
      'status': status,
      'razorpay_payment_id': paymentId,
    }).eq('id', orderId);
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      _orders = (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}