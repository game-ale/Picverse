import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:picverse/features/auth/presentation/bloc/auth_state.dart';
import 'package:picverse/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:picverse/features/auth/presentation/pages/login_screen.dart';
import 'package:picverse/features/auth/presentation/pages/register_screen.dart';
import 'package:picverse/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:picverse/features/auth/presentation/pages/splash_screen.dart';
import 'package:picverse/features/feed/presentation/pages/home_screen.dart';
import 'package:picverse/features/home/presentation/pages/main_screen.dart';
import 'package:picverse/features/notification/presentation/pages/notifications_screen.dart';
import 'package:picverse/features/post/presentation/pages/comments_screen.dart';
import 'package:picverse/features/post/presentation/pages/create_post_screen.dart';
import 'package:picverse/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:picverse/features/profile/presentation/pages/followers_list_screen.dart';
import 'package:picverse/features/profile/presentation/pages/profile_screen.dart';
import 'package:picverse/features/search/presentation/pages/search_screen.dart';
import 'package:picverse/core/services/auth_service.dart';

// ─── Transition helpers ───
CustomTransitionPage<void> _fadeTransition(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideUpTransition(
    Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.15), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

CustomTransitionPage<void> _slideRightTransition(
    Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0.25, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isOnAuth =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/reset-password' ||
            state.matchedLocation == '/splash';

        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return state.matchedLocation == '/splash' ? null : '/splash';
        }

        if (authState.status == AuthStatus.unauthenticated ||
            authState.status == AuthStatus.error) {
          return isOnAuth ? null : '/login';
        }

        if (authState.status == AuthStatus.authenticated && isOnAuth) {
          return '/';
        }

        return null;
      },
      routes: [
        // Auth routes — fade transitions
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) =>
              _fadeTransition(const SplashScreen(), state),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              _fadeTransition(const LoginScreen(), state),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) =>
              _fadeTransition(const RegisterScreen(), state),
        ),
        GoRoute(
          path: '/reset-password',
          pageBuilder: (context, state) =>
              _fadeTransition(const ResetPasswordScreen(), state),
        ),
        // Detail routes — slide transitions
        GoRoute(
          path: '/comments/:postId',
          pageBuilder: (context, state) {
            final postId = state.pathParameters['postId']!;
            return _slideUpTransition(
                CommentsScreen(postId: postId), state);
          },
        ),
        GoRoute(
          path: '/edit-profile',
          pageBuilder: (context, state) =>
              _slideRightTransition(const EditProfileScreen(), state),
        ),
        GoRoute(
          path: '/followers/:userId',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final tab = state.uri.queryParameters['tab'] ?? 'followers';
            return _slideRightTransition(
                FollowersListScreen(userId: userId, initialTab: tab), state);
          },
        ),
        GoRoute(
          path: '/profile/:userId',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return _slideRightTransition(
                ProfileScreen(userId: userId), state);
          },
        ),
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) =>
              _slideRightTransition(const AdminDashboardScreen(), state),
        ),
        // Main shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) => MainScreen(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/create-post',
              builder: (context, state) => const CreatePostScreen(),
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) {
                final uid = context.read<AuthService>().currentUser?.uid ?? '';
                return ProfileScreen(userId: uid);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// Converts a Stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
