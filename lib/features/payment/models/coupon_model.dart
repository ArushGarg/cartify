import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  const Coupon({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.finalAmount,
  });

  final String code;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final double finalAmount;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    code: json['code'] as String,
    discountType: json['discount_type'] as String,
    discountValue: (json['discount_value'] as num).toDouble(),
    discountAmount: (json['discount_amount'] as num).toDouble(),
    finalAmount: (json['final_amount'] as num).toDouble(),
  );

  String get label => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}% off'
      : '₹${discountValue.toStringAsFixed(0)} off';

  @override
  List<Object?> get props =>
      [code, discountType, discountValue, discountAmount, finalAmount];
}