// ============================================================================
// lib/presentation/widgets/dialogs/confirmation_dialog.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: AppConstants.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          if (icon != null) ...[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : ShadTheme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 30,
                color: isDestructive
                    ? Colors.red
                    : ShadTheme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLG),
          ],

          // Title
          Text(
            title,
            style: ShadTheme.of(
              context,
            ).textTheme.h4?.copyWith(fontWeight: FontWeight.w600),
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

          const SizedBox(height: AppConstants.spaceLG),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: ShadButton.outline(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop(false);
                  },
                  child: Text(cancelText),
                ),
              ),

              const SizedBox(width: AppConstants.spaceMD),

              // Confirm Button
              Expanded(
                child: isDestructive
                    ? ShadButton.destructive(
                        onPressed: () {
                          onConfirm?.call();
                          Navigator.of(context).pop(true);
                        },
                        child: Text(confirmText),
                      )
                    : ShadButton(
                        onPressed: () {
                          onConfirm?.call();
                          Navigator.of(context).pop(true);
                        },
                        child: Text(confirmText),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function to show confirmation dialog
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
  IconData? icon,
}) {
  return showShadDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
    ),
  );
}
