part of 'auth_bloc.dart';

/// Enum representing authentication status
enum AuthStatus { unknown, authenticated, unauthenticated }

/// State class for authentication
class AuthState extends Equatable {
  final AuthStatus status;
  final String? username;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.username,
    this.errorMessage,
  });

  /// Initial state when app starts
  const AuthState.unknown() : this(status: AuthStatus.unknown);

  /// State when user is authenticated
  const AuthState.authenticated(String username)
      : this(status: AuthStatus.authenticated, username: username);

  /// State when user is not authenticated
  const AuthState.unauthenticated({String? errorMessage})
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, username, errorMessage];
}
