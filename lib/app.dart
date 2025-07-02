// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'router/app_router.dart';
// import 'presentation/providers/app_state_provider.dart';

// class IProfitApp extends ConsumerWidget {
//   const IProfitApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(appRouterProvider);
//     final appState = ref.watch(appStateProvider);

//     return ShadApp.router(
//       title: 'IProfit',
//       routerConfig: router,
//       theme: ShadThemeData(
//         colorScheme: const ShadSlateColorScheme.light(),
//         brightness: Brightness.light,
//       ),
//       darkTheme: ShadThemeData(
//         colorScheme: const ShadSlateColorScheme.dark(),
//         brightness: Brightness.dark,
//       ),
//       themeMode: appState.themeMode,
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
