import 'package:equatable/equatable.dart';

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.createdAt,
  });

  final String id;
  final double totalAmount;
  final String status;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final DateTime createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    totalAmount: (json['total_amount'] as num).toDouble(),
    status: (json['status'] as String?) ?? 'pending',
    razorpayOrderId: (json['razorpay_order_id'] as String?) ?? '',
    razorpayPaymentId: (json['razorpay_payment_id'] as String?) ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  @override
  List<Object?> get props =>
      [id, totalAmount, status, razorpayOrderId, razorpayPaymentId, createdAt];
}