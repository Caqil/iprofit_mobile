// ============================================================================
// lib/presentation/widgets/common/app_bar.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../router/route_paths.dart';
import '../providers/app_state_provider.dart';

class IProfitAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showProfileAvatar;
  final bool showNotificationIcon;
  final bool centerTitle;
  final Widget? leading;
  final double? elevation;
  final Color? backgroundColor;

  const IProfitAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.showProfileAvatar = true,
    this.showNotificationIcon = true,
    this.centerTitle = true,
    this.leading,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? ShadTheme.of(context).colorScheme.background,
        border: Border(
          bottom: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppConstants.paddingHorizontalMD,
          child: Row(
            children: [
              // Leading Widget or Back Button
              if (leading != null)
                leading!
              else if (showBackButton && context.canPop())
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () => context.pop(),
                ),

              // Spacer for alignment
              if (centerTitle) const Spacer(),

              // Title
              if (title != null)
                Flexible(
                  child: Text(
                    title!,
                    style: ShadTheme.of(
                      context,
                    ).textTheme.h4?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  ),
                ),

              // Spacer for alignment
              if (centerTitle) const Spacer(),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // // Notification Icon
                  // if (showNotificationIcon) ...[
                  //   ShadButton.ghost(
                  //     size: ShadButtonSize.sm,
                  //     child: ShadBadge(
                  //       backgroundColor: appState.currentUser?.unreadNotifications > 0
                  //           ? ShadTheme.of(context).colorScheme.destructive
                  //           : Colors.transparent,
                  //       child: Icon(
                  //         LucideIcons.bell,
                  //         size: 20,
                  //         color: ShadTheme.of(context).colorScheme.foreground,
                  //       ),
                  //     ),
                  //     onPressed: () => context.push(RoutePaths.notifications),
                  //   ),
                  //   const SizedBox(width: AppConstants.spaceSM),
                  // ],

                  // Custom Actions
                  if (actions != null) ...actions!,

                  // Profile Avatar
                  if (showProfileAvatar && appState.currentUser != null) ...[
                    const SizedBox(width: AppConstants.spaceSM),
                    GestureDetector(
                      onTap: () => context.push(RoutePaths.profile),
                      child: ShadAvatar(
                        appState.currentUser?.profilePicture != null
                            ? null // Provide your Image widget here if available
                            : Text(
                                appState.currentUser?.name
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                                style: TextStyle(
                                  color: ShadTheme.of(
                                    context,
                                  ).colorScheme.primaryForeground,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        backgroundColor: ShadTheme.of(
                          context,
                        ).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
