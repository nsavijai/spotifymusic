import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/auth_user.dart';
import '../../data/providers/auth_repository_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/api_exception.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.user,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final AuthUser? user;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  Future<void> login({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.login(email: email, password: password);
      state = AuthState(isAuthenticated: true, user: user);
    } on ApiException catch (e) {
      state = AuthState(errorMessage: e.message);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  Future<void> register({required String email, required String username, required String password}) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.register(email: email, username: username, password: password);
      state = AuthState(isAuthenticated: true, user: user);
    } on ApiException catch (e) {
      state = AuthState(errorMessage: e.message);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

