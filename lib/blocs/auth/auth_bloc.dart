import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// AuthBloc handles authentication state management
/// following the Bloc architectural pattern
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState.unknown()) {
    // Register event handlers
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
  }

  /// Handles login request event
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final success = await authRepository.login(
        username: event.username,
        password: event.password,
      );
      
      if (success) {
        emit(AuthState.authenticated(event.username));
      } else {
        emit(const AuthState.unauthenticated(
          errorMessage: 'Invalid username or password',
        ));
      }
    } catch (e) {
      emit(AuthState.unauthenticated(
        errorMessage: 'Login failed: ${e.toString()}',
      ));
    }
  }

  /// Handles logout request event
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  /// Handles checking current authentication status
  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await authRepository.isAuthenticated();
    if (isAuthenticated) {
      final username = await authRepository.getCurrentUser();
      emit(AuthState.authenticated(username ?? 'User'));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }
}
