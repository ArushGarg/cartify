import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/payment_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController(text: 'Arush Garg');
  final _emailController =
  TextEditingController(text: 'arushgarg662@gmail.com');
  final _phoneController = TextEditingController(text: '8744055854');
  final _couponController = TextEditingController();

  double _discountAmount = 0;
  double _finalAmount = 0;
  String? _appliedCoupon;
  bool _isValidatingCoupon = false;
  String? _couponError;
  String? _couponSuccess;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _finalAmount = cart.totalAmount;

    final paymentProvider = context.read<PaymentProvider>();
    paymentProvider.initRazorpay();

    paymentProvider.onSuccess = (PaymentSuccessResponse response) async {
      final cart = context.read<CartProvider>();
      final orderProvider = context.read<OrderProvider>();

      final verified = await paymentProvider.verifyPayment(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
      );

      if (verified) {
        final items = cart.items
            .map((item) => {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        })
            .toList();

        final orderId = await orderProvider.createOrder(
          totalAmount: _finalAmount,
          razorpayOrderId: response.orderId!,
          items: items,
        );

        await orderProvider.updateOrderStatus(
          orderId: orderId!,
          status: 'paid',
          paymentId: response.paymentId!,
        );

        cart.clearCart();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(
                paymentId: response.paymentId!,
                amount: _finalAmount,
              ),
            ),
                (route) => route.isFirst,
          );
        }
      }
    };

    paymentProvider.onFailure = (PaymentFailureResponse response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
  }

  @override
  void dispose() {
    context.read<PaymentProvider>().dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
      _couponError = null;
      _couponSuccess = null;
    });

    final cart = context.read<CartProvider>();
    final result = await context
        .read<PaymentProvider>()
        .validateCoupon(code, cart.totalAmount);

    if (result == null) {
      setState(() {
        _couponError = 'Something went wrong';
        _isValidatingCoupon = false;
      });
      return;
    }

    if (result.containsKey('error')) {
      setState(() {
        _couponError = result['error'];
        _discountAmount = 0;
        _finalAmount = cart.totalAmount;
        _appliedCoupon = null;
        _isValidatingCoupon = false;
      });
      return;
    }

    setState(() {
      _discountAmount = (result['discount_amount'] as num).toDouble();
      _finalAmount = (result['final_amount'] as num).toDouble();
      _appliedCoupon = result['code'];
      _couponSuccess =
      '${result['discount_type'] == 'percentage' ? '${result['discount_value']}%' : '₹${result['discount_value']}'} discount applied!';
      _isValidatingCoupon = false;
    });
  }

  void _removeCoupon() {
    final cart = context.read<CartProvider>();
    setState(() {
      _discountAmount = 0;
      _finalAmount = cart.totalAmount;
      _appliedCoupon = null;
      _couponController.clear();
      _couponError = null;
      _couponSuccess = null;
    });
  }

  Future<void> _startPayment() async {
    final paymentProvider = context.read<PaymentProvider>();
    final orderId = await paymentProvider.createOrder(_finalAmount);

    if (orderId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start payment. Try again.'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    paymentProvider.openPaymentSheet(
      orderId: orderId,
      amount: _finalAmount,
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      customerPhone: _phoneController.text,
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Order Summary'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.product.name} x${item.quantity}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  )),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppTheme.border, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13)),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Discount',
                                style: TextStyle(
                                    color: AppTheme.success,
                                    fontSize: 13)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _appliedCoupon ?? '',
                                style: const TextStyle(
                                    color: AppTheme.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '- ₹${_discountAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppTheme.border, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        '₹${_finalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Coupon Section
            _sectionLabel('Apply Coupon'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_appliedCoupon == null)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            textCapitalization:
                            TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Enter coupon code',
                              prefixIcon: Icon(
                                  Icons.local_offer_outlined,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed:
                          _isValidatingCoupon ? null : _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                          child: _isValidatingCoupon
                              ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2),
                          )
                              : const Text('Apply'),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppTheme.success, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$_appliedCoupon applied — saving ₹${_discountAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _removeCoupon,
                            child: const Icon(Icons.close,
                                color: AppTheme.success, size: 18),
                          ),
                        ],
                      ),
                    ),
                  if (_couponError != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.error, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _couponError!,
                            style: const TextStyle(
                                color: AppTheme.error, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_couponSuccess != null &&
                      _appliedCoupon != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _couponSuccess!,
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Try: CARTIFY10 • FLAT200 • WELCOME20 • SAVE500',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Details
            _sectionLabel('Your Details'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 32),

            // Pay Button
            Consumer<PaymentProvider>(
              builder: (context, provider, _) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _startPayment,
                  child: provider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    _discountAmount > 0
                        ? 'Pay ₹${_finalAmount.toStringAsFixed(0)} (Saved ₹${_discountAmount.toStringAsFixed(0)})'
                        : 'Pay ₹${_finalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}