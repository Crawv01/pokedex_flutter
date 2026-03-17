import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokedex_app/blocs/auth/auth_bloc.dart';
import 'package:pokedex_app/repositories/auth_repository.dart';

// Mock class for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthRepository authRepository;
    late AuthBloc authBloc;

    setUp(() {
      authRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: authRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthState.unknown', () {
      expect(authBloc.state, const AuthState.unknown());
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [authenticated] when login succeeds',
        build: () {
          when(() => authRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => true);
          return AuthBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          username: 'testuser',
          password: 'testpass',
        )),
        expect: () => [
          const AuthState.authenticated('testuser'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] with error when login fails',
        build: () {
          when(() => authRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => false);
          return AuthBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          username: 'testuser',
          password: 'wrongpass',
        )),
        expect: () => [
          const AuthState.unauthenticated(
            errorMessage: 'Invalid username or password',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] with error when login throws exception',
        build: () {
          when(() => authRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Network error'));
          return AuthBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          username: 'testuser',
          password: 'testpass',
        )),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.errorMessage, 'errorMessage', contains('Login failed')),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when logout is requested',
        build: () {
          when(() => authRepository.logout()).thenAnswer((_) async {});
          return AuthBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthState.unauthenticated(),
        ],
      );
    });

    group('AuthStatusChecked', () {
      blocTest<AuthBloc, AuthState>(
        'emits [authenticated] when user is already logged in',
        build: () {
          when(() => authRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => authRepository.getCurrentUser())
              .thenAnswer((_) async => 'saveduser');
          return AuthBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const AuthStatusChecked()),
        expect: () => [
          const AuthState.authenticated('saveduser'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when user is not logged in',
        build: () {
          when(() => authRepository.isAuthenticated())
              .thenAnswer((_) async => false);
          return AuthBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const AuthStatusChecked()),
        expect: () => [
          const AuthState.unauthenticated(),
        ],
      );
    });
  });

  group('AuthState', () {
    test('supports value equality', () {
      expect(
        const AuthState.authenticated('user1'),
        const AuthState.authenticated('user1'),
      );
    });

    test('different usernames are not equal', () {
      expect(
        const AuthState.authenticated('user1'),
        isNot(const AuthState.authenticated('user2')),
      );
    });

    test('props are correct', () {
      const state = AuthState(
        status: AuthStatus.authenticated,
        username: 'testuser',
        errorMessage: null,
      );
      expect(state.props, [AuthStatus.authenticated, 'testuser', null]);
    });
  });

  group('AuthEvent', () {
    test('AuthLoginRequested supports value equality', () {
      expect(
        const AuthLoginRequested(username: 'user', password: 'pass'),
        const AuthLoginRequested(username: 'user', password: 'pass'),
      );
    });

    test('AuthLoginRequested props are correct', () {
      const event = AuthLoginRequested(username: 'user', password: 'pass');
      expect(event.props, ['user', 'pass']);
    });

    test('AuthLogoutRequested supports value equality', () {
      expect(
        const AuthLogoutRequested(),
        const AuthLogoutRequested(),
      );
    });

    test('AuthStatusChecked supports value equality', () {
      expect(
        const AuthStatusChecked(),
        const AuthStatusChecked(),
      );
    });
  });
}
