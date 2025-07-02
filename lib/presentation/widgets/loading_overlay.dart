
// ============================================================================
// lib/presentation/widgets/overlays/loading_overlay.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final bool showProgress;
  final double? progress;
  final Color? backgroundColor;
  final bool canDismiss;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.showProgress = false,
    this.progress,
    this.backgroundColor,
    this.canDismiss = false,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: child,
              );
            },
            child: _LoadingOverlayContent(
              message: widget.message,
              showProgress: widget.showProgress,
              progress: widget.progress,
              backgroundColor: widget.backgroundColor,
              canDismiss: widget.canDismiss,
            ),
          ),
      ],
    );
  }
}

class _LoadingOverlayContent extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final Color? backgroundColor;
  final bool canDismiss;

  const _LoadingOverlayContent({
    this.message,
    this.showProgress = false,
    this.progress,
    this.backgroundColor,
    this.canDismiss = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: GestureDetector(
        onTap: canDismiss ? () => Navigator.of(context).pop() : null,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              margin: AppConstants.paddingLG,
              padding: AppConstants.paddingLG,
              decoration: BoxDecoration(
                color: ShadTheme.of(context).colorScheme.background,
                borderRadius: AppConstants.borderRadiusLG,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading Indicator
                  if (showProgress && progress != null)
                    Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor: ShadTheme.of(context).colorScheme.muted,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ShadTheme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceMD),
                        ShadProgress(
                          value: progress!,
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ShadTheme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // Loading Message
                  if (message != null) ...[
                    Text(
                      message!,
                      style: ShadTheme.of(context).textTheme.p,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                  ],

                  // Progress Percentage
                  if (showProgress && progress != null) ...[
                    Text(
                      '${(progress! * 100).toInt()}%',
                      style: ShadTheme.of(context).textTheme.small?.copyWith(
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  // Dismiss hint
                  if (canDismiss) ...[
                    const SizedBox(height: AppConstants.spaceMD),
                    Text(
                      'Tap anywhere to dismiss',
                      style: ShadTheme.of(context).textTheme.small?.copyWith(
                        color: ShadTheme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to show loading overlay
void showLoadingOverlay(
  BuildContext context, {
  String? message,
  bool showProgress = false,
  double? progress,
  bool canDismiss = false,
}) {
  showShadDialog(
    context: context,
    barrierDismissible: canDismiss,
    builder: (context) => _LoadingOverlayContent(
      message: message,
      showProgress: showProgress,
      progress: progress,
      canDismiss: canDismiss,
    ),
  );
}
