class OrderModel {
  final String id;
  final double totalAmount;
  final String status;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      razorpayPaymentId: json['razorpay_payment_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}