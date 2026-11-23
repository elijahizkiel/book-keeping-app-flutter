import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookkeeping_app/features/splash/splash_view.dart';
import 'package:bookkeeping_app/features/onboarding/onboarding_view.dart';
import 'package:bookkeeping_app/features/dashboard/dashboard_view.dart';
import 'package:bookkeeping_app/features/transactions/transactions_view.dart';
import 'package:bookkeeping_app/features/transactions/add_transaction_view.dart';
import 'package:bookkeeping_app/features/transactions/transaction_detail_view.dart';
import 'package:bookkeeping_app/features/friends/friends_view.dart';
import 'package:bookkeeping_app/features/friends/add_friend_view.dart';
import 'package:bookkeeping_app/features/friends/friend_detail_view.dart';
import 'package:bookkeeping_app/features/settings/settings_view.dart';
import 'package:bookkeeping_app/features/help/help_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      // App Shell with Bottom Navigation Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Transactions',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Friends',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                builder: (context, state) => const FriendsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          ),
        ],
      ),
      // Sub-routes outside Bottom Bar
      GoRoute(
        path: '/transactions/new',
        builder: (context, state) {
          final friendId = state.uri.queryParameters['friendId'];
          return AddTransactionView(initialFriendId: friendId);
        },
      ),
      GoRoute(
        path: '/transactions/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddTransactionView(transactionId: id);
        },
      ),
      GoRoute(
        path: '/transactions/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailView(transactionId: id);
        },
      ),
      GoRoute(
        path: '/friends/new',
        builder: (context, state) => const AddFriendView(),
      ),
      GoRoute(
        path: '/friends/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FriendDetailView(friendId: id);
        },
      ),
      GoRoute(path: '/help', builder: (context, state) => const HelpView()),
    ],
  );
});
