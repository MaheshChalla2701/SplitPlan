import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/friends/presentation/screens/friend_detail_screen.dart';
import '../../features/friends/presentation/screens/friend_search_screen.dart';
import '../../features/friends/presentation/screens/new_chat_screen.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/payments/presentation/screens/create_payment_request_screen.dart';
import '../../features/groups/presentation/screens/group_details_screen.dart';
import '../../features/groups/presentation/screens/home_screen.dart';
import '../../features/settlements/presentation/screens/settle_up_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final hasError = authState.hasError;
      final isAuthenticated = authState.valueOrNull != null;

      final isSplash = state.uri.toString() == '/';
      final isLogin = state.uri.toString() == '/login';
      final isAuthRoute =
          isLogin ||
          state.uri.toString() == '/signup' ||
          state.uri.toString() == '/auth/forgot-password' ||
          state.uri.toString() == '/phone-login' ||
          state.uri.toString() == '/otp-verify';

      if (isLoading || hasError) {
        return null; // Let splash screen handle loading/error
      }

      if (!isAuthenticated) {
        if (isAuthRoute) return null;
        return '/login';
      }

      if (isAuthenticated && (isSplash || isLogin)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final verificationId = state.extra as String;
          return OtpVerificationScreen(verificationId: verificationId);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/friends/search',
        builder: (context, state) => const FriendSearchScreen(),
      ),
      GoRoute(
        path: '/new-chat',
        builder: (context, state) => const NewChatScreen(),
      ),
      GoRoute(
        path: '/friends/:id',
        builder: (context, state) {
          final friendId = state.pathParameters['id']!;
          return FriendDetailScreen(friendId: friendId);
        },
        routes: [
          GoRoute(
            path: 'create-request',
            builder: (context, state) {
              final friendId = state.pathParameters['id']!;
              return CreatePaymentRequestScreen(friendId: friendId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GroupDetailsScreen(groupId: id);
        },
        routes: [
          GoRoute(
            path: 'add-expense',
            builder: (context, state) {
              final groupId = state.pathParameters['id']!;
              final existingExpense = state.extra as ExpenseEntity?;
              return AddExpenseScreen(
                groupId: groupId,
                existingExpense: existingExpense,
              );
            },
          ),
          GoRoute(
            path: 'settle',
            builder: (context, state) {
              final groupId = state.pathParameters['id']!;
              final toUserId = state.uri.queryParameters['toUserId']!;
              final amount = double.parse(state.uri.queryParameters['amount']!);
              return SettleUpScreen(
                groupId: groupId,
                toUserId: toUserId,
                amount: amount,
              );
            },
          ),
        ],
      ),
    ],
  );
}
