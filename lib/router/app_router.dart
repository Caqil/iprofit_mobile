// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../presentation/providers/auth_provider.dart';
// import '../presentation/screens/auth/login_screen.dart';
// import '../presentation/screens/auth/register_screen.dart';
// import '../presentation/screens/dashboard/dashboard_screen.dart';
// import '../presentation/screens/wallet/wallet_screen.dart';
// import '../presentation/screens/wallet/deposit_screen.dart';
// import '../presentation/screens/wallet/withdrawal_screen.dart';
// import '../presentation/screens/portfolio/portfolio_screen.dart';
// import '../presentation/screens/loans/loans_screen.dart';
// import '../presentation/screens/loans/loan_application_screen.dart';
// import '../presentation/screens/tasks/tasks_screen.dart';
// import '../presentation/screens/referrals/referrals_screen.dart';
// import '../presentation/screens/kyc/kyc_screen.dart';
// import '../presentation/screens/profile/profile_screen.dart';
// import '../presentation/screens/notifications/notifications_screen.dart';
// import 'route_paths.dart';

// final appRouterProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authProvider);

//   return GoRouter(
//     initialLocation: RoutePaths.dashboard,
//     redirect: (context, state) {
//       final isLoggedIn = authState.isAuthenticated;
//       final isAuthRoute = [
//         RoutePaths.login,
//         RoutePaths.register,
//         RoutePaths.forgotPassword,
//       ].contains(state.matchedLocation);

//       if (!isLoggedIn && !isAuthRoute) {
//         return RoutePaths.login;
//       }

//       if (isLoggedIn && isAuthRoute) {
//         return RoutePaths.dashboard;
//       }

//       return null;
//     },
//     routes: [
//       // Auth routes
//       GoRoute(
//         path: RoutePaths.login,
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: RoutePaths.register,
//         builder: (context, state) => const RegisterScreen(),
//       ),

//       // Main app shell with bottom navigation
//       ShellRoute(
//         builder: (context, state, child) => MainShell(child: child),
//         routes: [
//           GoRoute(
//             path: RoutePaths.dashboard,
//             builder: (context, state) => const DashboardScreen(),
//           ),
//           GoRoute(
//             path: RoutePaths.wallet,
//             builder: (context, state) => const WalletScreen(),
//             routes: [
//               GoRoute(
//                 path: 'deposit',
//                 builder: (context, state) => const DepositScreen(),
//               ),
//               GoRoute(
//                 path: 'withdraw',
//                 builder: (context, state) => const WithdrawalScreen(),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: RoutePaths.portfolio,
//             builder: (context, state) => const PortfolioScreen(),
//           ),
//           GoRoute(
//             path: RoutePaths.loans,
//             builder: (context, state) => const LoansScreen(),
//             routes: [
//               GoRoute(
//                 path: 'apply',
//                 builder: (context, state) => const LoanApplicationScreen(),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: RoutePaths.tasks,
//             builder: (context, state) => const TasksScreen(),
//           ),
//           GoRoute(
//             path: RoutePaths.referrals,
//             builder: (context, state) => const ReferralsScreen(),
//           ),
//           GoRoute(
//             path: RoutePaths.kyc,
//             builder: (context, state) => const KycScreen(),
//           ),
//           GoRoute(
//             path: RoutePaths.profile,
//             builder: (context, state) => const ProfileScreen(),
//           ),
//           GoRoute(
//             path: RoutePaths.notifications,
//             builder: (context, state) => const NotificationsScreen(),
//           ),
//         ],
//       ),
//     ],
//   );
// });

// class MainShell extends ConsumerWidget {
//   final Widget child;

//   const MainShell({Key? key, required this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(body: child, bottomNavigationBar: const BottomNavBar());
//   }
// }
