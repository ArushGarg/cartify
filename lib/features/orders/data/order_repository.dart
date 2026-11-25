import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cart/models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._client);
  final SupabaseClient _client;

  /// Called only AFTER the backend has verified the payment signature,
  /// so the order is written once, already as 'paid'.
  Future<String> createPaidOrder({
    required double totalAmount,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required List<CartItem> items,
  }) async {
    final order = await _client
        .from('orders')
        .insert({
      'user_id': _client.auth.currentUser?.id,
      'total_amount': totalAmount,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'status': 'paid',
    })
        .select()
        .single();

    final orderId = order['id'] as String;

    await _client.from('order_items').insert([
      for (final i in items)
        {
          'order_id': orderId,
          'product_id': i.product.id,
          'quantity': i.quantity,
          'price': i.product.price,
        },
    ]);

    return orderId;
  }

  Future<List<OrderModel>> fetchOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((j) => OrderModel.fromJson(Map<String, dynamic>.from(j as Map)))
        .toList();
  }
}