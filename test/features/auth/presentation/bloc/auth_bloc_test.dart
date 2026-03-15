import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_event.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  final tUser = createTestUser();

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() => authBloc.close());

  group('AuthBloc', () {
    test('initial state is correct', () {
      expect(authBloc.state, const AuthState());
      expect(authBloc.state.status, AuthStatus.initial);
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [authenticated] when user is logged in',
        setUp: () {
          final mockUser = MockUser();
          when(() => mockAuthRepository.currentUser).thenReturn(mockUser);
          when(
            () => mockAuthRepository.getCurrentUserProfile(),
          ).thenAnswer((_) async => tUser);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when no user',
        setUp: () {
          when(() => mockAuthRepository.currentUser).thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
      );
    });

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on success',
        setUp: () {
          when(
            () => mockAuthRepository.signInWithEmail(any(), any()),
          ).thenAnswer((_) async => tUser);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@test.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on FirebaseAuthException',
        setUp: () {
          when(
            () => mockAuthRepository.signInWithEmail(any(), any()),
          ).thenThrow(
            FirebaseAuthException(code: 'user-not-found', message: ''),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AuthLoginRequested(email: 'test@test.com', password: 'wrong'),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'No account found with this email',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on generic exception',
        setUp: () {
          when(
            () => mockAuthRepository.signInWithEmail(any(), any()),
          ).thenThrow(Exception('network error'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@test.com',
            password: 'password',
          ),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'An unexpected error occurred',
          ),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on success',
        setUp: () {
          when(
            () => mockAuthRepository.registerWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            ),
          ).thenAnswer((_) async => tUser);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            email: 'test@test.com',
            password: 'password123',
            username: 'testuser',
          ),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when email already in use',
        setUp: () {
          when(
            () => mockAuthRepository.registerWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              username: any(named: 'username'),
            ),
          ).thenThrow(
            FirebaseAuthException(code: 'email-already-in-use', message: ''),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            email: 'test@test.com',
            password: 'password123',
            username: 'testuser',
          ),
        ),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'An account already exists with this email',
          ),
        ],
      );
    });

    group('AuthGoogleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when Google sign-in succeeds',
        setUp: () {
          when(
            () => mockAuthRepository.signInWithGoogle(),
          ).thenAnswer((_) async => tUser);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when user cancels',
        setUp: () {
          when(
            () => mockAuthRepository.signInWithGoogle(),
          ).thenAnswer((_) async => null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(
            () => mockAuthRepository.signInWithGoogle(),
          ).thenThrow(Exception('failed'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthGoogleSignInRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'Google sign-in failed',
          ),
        ],
      );
    });

    group('AuthResetPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, resetPasswordSent] on success',
        setUp: () {
          when(
            () => mockAuthRepository.resetPassword(any()),
          ).thenAnswer((_) async {});
        },
        build: () => authBloc,
        act: (bloc) =>
            bloc.add(const AuthResetPasswordRequested(email: 'test@test.com')),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.resetPasswordSent),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on failure',
        setUp: () {
          when(
            () => mockAuthRepository.resetPassword(any()),
          ).thenThrow(Exception('failed'));
        },
        build: () => authBloc,
        act: (bloc) =>
            bloc.add(const AuthResetPasswordRequested(email: 'test@test.com')),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.error,
            errorMessage: 'Failed to send reset email',
          ),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] on logout',
        setUp: () {
          when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [const AuthState(status: AuthStatus.unauthenticated)],
      );
    });
  });
}
