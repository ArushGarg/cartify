import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/auth_cubit.dart';
import 'otp_verified_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;
  static const _expirySeconds = 300;

  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _expirySeconds;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // never stack timers on resend
    setState(() => _secondsLeft = _expirySeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _snack(String message, {bool error = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? AppTheme.error : AppTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _verify() {
    final cubit = context.read<AuthCubit>();
    if (cubit.state.isBusy) return; // auto-submit + button tap can't double fire
    if (_otp.length != _length) {
      _snack('Enter the 6-digit code');
      return;
    }
    cubit.verifyOtp(_otp);
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);

    final error = await context.read<AuthCubit>().resendOtp();

    if (!mounted) return;
    setState(() => _resending = false);

    if (error == null) {
      _startTimer();
      _snack('OTP resent', error: false);
    } else {
      _snack(error);
    }
  }

  void _clearBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthCubit c) => c.state.isBusy);

    return BlocListener<AuthCubit, AuthFlowState>(
      // Only the result of a verify request started on THIS screen
      listenWhen: (prev, curr) =>
      prev.status == AuthFlowStatus.verifying &&
          (curr.status == AuthFlowStatus.authenticated ||
              curr.status == AuthFlowStatus.failure),
      listener: (context, state) {
        if (state.status == AuthFlowStatus.authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OtpVerifiedScreen()),
                (route) => false,
          );
        } else {
          _snack(state.errorMessage ?? 'Invalid OTP');
          _clearBoxes();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.dialpad_rounded,
                          color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter OTP',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        Text('Sent to ${widget.phone}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_length, _digitBox),
                ),
                const SizedBox(height: 32),
                Container(
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
                      onTap: busy ? null : _verify,
                      child: Center(
                        child: busy
                            ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text('Verify & Continue',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Didn't receive code? ",
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: (busy || _resending) ? null : _resend,
                        child: Text(_resending ? 'Sending…' : 'Resend OTP',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: _secondsLeft == 0
                        ? const Text('OTP expired — tap Resend OTP',
                        style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600))
                        : Text.rich(
                      TextSpan(
                        text: 'OTP expires in ',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        children: [
                          TextSpan(
                            text: _timerText,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _digitBox(int i) {
    final filled = _controllers[i].text.isNotEmpty;
    final borderColor = filled ? AppTheme.primary : AppTheme.border;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[i],
        focusNode: _focusNodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: filled ? AppTheme.primary : AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: filled
              ? AppTheme.primary.withValues(alpha: 0.06)
              : AppTheme.surface,
          contentPadding: EdgeInsets.zero,
          border: border(borderColor, filled ? 1.5 : 1),
          enabledBorder: border(borderColor, filled ? 1.5 : 1),
          focusedBorder: border(AppTheme.primary, 2),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && i < _length - 1) {
            _focusNodes[i + 1].requestFocus();
          } else if (value.isEmpty && i > 0) {
            _focusNodes[i - 1].requestFocus();
          }
          if (i == _length - 1 && value.isNotEmpty) _verify();
        },
      ),
    );
  }
}