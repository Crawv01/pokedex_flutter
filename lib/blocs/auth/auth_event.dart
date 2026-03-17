part of 'auth_bloc.dart';

/// Abstract base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user attempts to log in
class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

/// Event triggered when user logs out
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event triggered to check current authentication status
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}
