import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../bloc/checkout_bloc.dart';
import 'order_success_screen.dart';

const _navy = Color(0xFF0F1729);
const _card = Color(0xFF1A2540);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _coupon = TextEditingController();
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: context.read<AuthCubit>().phone10);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _coupon.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, CheckoutState state) {
    switch (state.status) {
      case CheckoutStatus.success:
        context.read<CartCubit>().clearCart();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              paymentId: state.paymentId ?? '',
              amount: state.paidAmount ?? state.total,
            ),
          ),
              (route) => route.isFirst,
        );
      case CheckoutStatus.failure:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'Payment failed'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ));
      default:
        break;
    }
  }

  void _pay(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<CheckoutBloc>().add(PayPressed(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onState,
      builder: (context, state) {
        final verifying = state.status == CheckoutStatus.verifying;
        final paying = state.status == CheckoutStatus.creatingOrder || verifying;

        return PopScope(
          canPop: !verifying, // don't let the user leave mid-verification
          child: Scaffold(
            backgroundColor: _navy,
            appBar: AppBar(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              title: const Text('Checkout',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Order Summary'),
                    _summary(state),
                    const SizedBox(height: 24),
                    _label('Apply Coupon'),
                    _couponCard(context, state),
                    const SizedBox(height: 24),
                    _label('Your Details'),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration('Full name'),
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration('Email'),
                      validator: (v) =>
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v?.trim() ?? '')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white),
                      decoration: _decoration('Phone').copyWith(counterText: ''),
                      validator: (v) => RegExp(r'^\d{10}$').hasMatch(v ?? '')
                          ? null
                          : 'Enter a 10-digit number',
                    ),
                    const SizedBox(height: 28),
                    _payButton(context, state, paying, verifying),
                    const SizedBox(height: 12),
                    const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline,
                              color: Colors.white38, size: 14),
                          SizedBox(width: 6),
                          Text('Secured by Razorpay',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── pieces ──

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800)),
  );

  InputDecoration _decoration(String label) {
    OutlineInputBorder border(Color color, [double width = 0]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: width == 0
              ? BorderSide.none
              : BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: _card,
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(AppTheme.primary, 1.5),
      errorBorder: border(AppTheme.error, 1),
      focusedErrorBorder: border(AppTheme.error, 1.5),
    );
  }

  Widget _summary(CheckoutState state) {
    Widget row(String left, String right,
        {Color? color, bool bold = false, double size = 13}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(left,
                  style: TextStyle(
                      color: color ?? Colors.white54,
                      fontSize: size,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
              Text(right,
                  style: TextStyle(
                      color: color ?? Colors.white,
                      fontSize: size,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
      BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          for (final item in state.items)
            row('${item.product.name} × ${item.quantity}',
                '₹${item.totalPrice.toStringAsFixed(0)}',
                size: 14),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white12, height: 1),
          ),
          row('Subtotal', '₹${state.subtotal.toStringAsFixed(0)}'),
          if (state.coupon != null)
            row('Discount (${state.coupon!.code})',
                '− ₹${state.discount.toStringAsFixed(0)}',
                color: AppTheme.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.white12, height: 1),
          ),
          row('Total', '₹${state.total.toStringAsFixed(0)}',
              bold: true, size: 17, color: Colors.white),
        ],
      ),
    );
  }

  Widget _couponCard(BuildContext context, CheckoutState state) {
    final applying = state.status == CheckoutStatus.applyingCoupon;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
      BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.coupon == null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coupon,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.local_offer_outlined,
                          color: Colors.white38),
                      filled: true,
                      fillColor: _navy,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: applying
                      ? null
                      : () => context
                      .read<CheckoutBloc>()
                      .add(CouponApplied(_coupon.text)),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: applying
                          ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                          : const Text('Apply',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppTheme.success, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${state.coupon!.code} applied — ${state.coupon!.label}, '
                          'you save ₹${state.discount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _coupon.clear();
                      context.read<CheckoutBloc>().add(const CouponRemoved());
                    },
                    child: const Icon(Icons.close,
                        color: AppTheme.success, size: 20),
                  ),
                ],
              ),
            ),
          if (state.couponError != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.error, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(state.couponError!,
                      style: const TextStyle(
                          color: AppTheme.error, fontSize: 12)),
                ),
              ],
            ),
          ],
          if (state.coupon == null) ...[
            const SizedBox(height: 10),
            const Text('Try: CARTIFY10 · FLAT200 · WELCOME20 · SAVE500',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ],
      ),
    );
  }

  Widget _payButton(
      BuildContext context, CheckoutState state, bool paying, bool verifying) {
    final label = state.discount > 0
        ? 'Pay ₹${state.total.toStringAsFixed(0)}  (saved ₹${state.discount.toStringAsFixed(0)})'
        : 'Pay ₹${state.total.toStringAsFixed(0)}';

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(50),
        boxShadow: AppTheme.primaryShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: (state.isBusy || state.items.isEmpty)
              ? null
              : () => _pay(context),
          child: Center(
            child: paying
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
                if (verifying) ...[
                  const SizedBox(width: 12),
                  const Text('Verifying payment…',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ],
              ],
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}