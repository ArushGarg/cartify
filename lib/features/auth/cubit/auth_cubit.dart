import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';

// Named AuthFlow* because supabase_flutter already exports a class called AuthState
enum AuthFlowStatus {
  unauthenticated,
  sendingOtp,
  otpSent,
  verifying,
  authenticated,
  failure,
}

class AuthFlowState extends Equatable {
  const AuthFlowState({required this.status, this.phone, this.errorMessage});

  final AuthFlowStatus status;
  final String? phone;
  final String? errorMessage;

  bool get isBusy =>
      status == AuthFlowStatus.sendingOtp || status == AuthFlowStatus.verifying;

  AuthFlowState copyWith({
    AuthFlowStatus? status,
    String? phone,
    String? errorMessage,
  }) =>
      AuthFlowState(
        status: status ?? this.status,
        phone: phone ?? this.phone,
        errorMessage: errorMessage, // intentionally not preserved
      );

  @override
  List<Object?> get props => [status, phone, errorMessage];
}

class AuthCubit extends Cubit<AuthFlowState> {
  AuthCubit(AuthRepository repo)
      : _repo = repo,
        super(AuthFlowState(
        status: repo.isLoggedIn
            ? AuthFlowStatus.authenticated
            : AuthFlowStatus.unauthenticated,
      ));

  final AuthRepository _repo;

  /// Logged-in user's 10-digit number (Supabase stores it as 91XXXXXXXXXX)
  String get phone10 {
    final digits =
    (state.phone ?? _repo.phone ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 ? digits.substring(digits.length - 10) : '';
  }

  Future<void> sendOtp(String phone) async {
    emit(state.copyWith(status: AuthFlowStatus.sendingOtp, phone: phone));
    try {
      await _repo.sendOtp(phone);
      emit(state.copyWith(status: AuthFlowStatus.otpSent));
    } on AuthFailure catch (e) {
      emit(state.copyWith(
          status: AuthFlowStatus.failure, errorMessage: e.message));
    }
  }

  /// Returns null on success, or an error message.
  /// Deliberately emits NOTHING: the Login screen is still alive under the
  /// OTP screen, and any status change here could trigger its listener.
  Future<String?> resendOtp() async {
    final phone = state.phone;
    if (phone == null) {
      return 'Session expired. Go back and enter your number again.';
    }
    try {
      await _repo.sendOtp(phone);
      return null;
    } on AuthFailure catch (e) {
      return e.message;
    }
  }

  Future<void> verifyOtp(String otp) async {
    final phone = state.phone;
    if (phone == null) return;
    emit(state.copyWith(status: AuthFlowStatus.verifying));
    try {
      await _repo.verifyOtp(phone, otp);
      emit(state.copyWith(status: AuthFlowStatus.authenticated));
    } on AuthFailure catch (e) {
      emit(state.copyWith(
          status: AuthFlowStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthFlowState(status: AuthFlowStatus.unauthenticated));
  }
}