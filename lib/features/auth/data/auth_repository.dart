import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  bool get isLoggedIn => _client.auth.currentSession != null;
  String? get phone => _client.auth.currentUser?.phone;

  Future<void> sendOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Network error. Check your connection.');
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    try {
      await _client.auth.verifyOTP(phone: phone, token: otp, type: OtpType.sms);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw const AuthFailure('Network error. Check your connection.');
    }
  }

  Future<void> signOut() => _client.auth.signOut();
}