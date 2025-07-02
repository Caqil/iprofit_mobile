
// ============================================================================
// lib/presentation/widgets/dialogs/error_dialog.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showRetry;
  final AppException? exception;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'OK',
    this.onRetry,
    this.onClose,
    this.showRetry = false,
    this.exception,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: AppConstants.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ShadTheme.of(context).colorScheme.destructive.withOpacity(0.1),
            ),
            child: Icon(
              LucideIcons.circleAlert,
              size: 30,
              color: ShadTheme.of(context).colorScheme.destructive,
            ),
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // Title
          Text(
            title,
            style: ShadTheme.of(context).textTheme.h4?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spaceMD),

          // Message
          Text(
            message,
            style: ShadTheme.of(context).textTheme.p?.copyWith(
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),

          // Exception Details (in debug mode)
          if (exception != null) ...[
            const SizedBox(height: AppConstants.spaceMD),
            
            ExpansionTile(
              title: const Text('Technical Details'),
              children: [
                Container(
                  width: double.infinity,
                  padding: AppConstants.paddingSM,
                  decoration: BoxDecoration(
                    color: ShadTheme.of(context).colorScheme.muted,
                    borderRadius: AppConstants.borderRadiusSM,
                  ),
                  child: Text(
                    'Type: ${exception.runtimeType}\n'
                    'Code: ${exception!.hashCode}\n'
                    'Details: ${exception!.message}',
                    style: ShadTheme.of(context).textTheme.small.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppConstants.spaceLG),

          // Action Buttons
          if (showRetry && onRetry != null)
            Row(
              children: [
                // Close Button
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () {
                      onClose?.call();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ),

                const SizedBox(width: AppConstants.spaceMD),

                // Retry Button
                Expanded(
                  child: ShadButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry?.call();
                    },
                    child: const Text('Retry'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: () {
                  onClose?.call();
                  Navigator.of(context).pop();
                },
                child: Text(buttonText),
              ),
            ),
        ],
      ),
    );
  }
}

// Helper function to show error dialog
Future<void> showErrorDialog(
  BuildContext context, {
  String title = 'Error',
  required String message,
  String buttonText = 'OK',
  VoidCallback? onRetry,
  VoidCallback? onClose,
  bool showRetry = false,
  AppException? exception,
}) {
  return showShadDialog(
    context: context,
    builder: (context) => ErrorDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onRetry: onRetry,
      onClose: onClose,
      showRetry: showRetry,
      exception: exception,
    ),
  );
}
