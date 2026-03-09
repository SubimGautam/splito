import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../data/datasource/remote/remote_auth_datasource.dart';
import '../../data/datasource/local/local_auth_datasource.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<Map<String, dynamic>?>>((ref) {
  final remoteDataSource = ref.watch(remoteAuthDataSourceProvider);
  final localDataSource = ref.watch(localAuthDataSourceProvider);
  return AuthViewModel(remoteDataSource, localDataSource);
});

class AuthViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final RemoteAuthDataSourceImpl _remoteDataSource;
  final LocalAuthDataSourceImpl _localDataSource;
  
  AuthViewModel(this._remoteDataSource, this._localDataSource) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password, bool rememberMe) async {
    state = const AsyncValue.loading();
    try {
      final result = await _remoteDataSource.signIn(email, password);
      
      if (rememberMe) {
        await _localDataSource.saveCredentials(email, password);
      }
      
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _remoteDataSource.signUp(
        username,
        email,
        password,
        confirmPassword,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      final result = await _remoteDataSource.forgotPassword(email);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    state = const AsyncValue.loading();
    try {
      final result = await _remoteDataSource.verifyCode(email, code);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> resetPassword(String resetToken, String password, String confirmPassword) async {
    state = const AsyncValue.loading();
    try {
      final result = await _remoteDataSource.resetPassword(resetToken, password, confirmPassword);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _remoteDataSource.logout();
    state = const AsyncValue.data(null);
  }
}