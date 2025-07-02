// ============================================================================
// lib/presentation/widgets/dialogs/success_dialog.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/constants/app_constants.dart';

class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onClose;
  final IconData? icon;
  final bool autoClose;
  final Duration autoCloseDuration;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onClose,
    this.icon,
    this.autoClose = false,
    this.autoCloseDuration = const Duration(seconds: 3),
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });

    // Auto close if enabled
    if (widget.autoClose) {
      Future.delayed(widget.autoCloseDuration, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onClose?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: AppConstants.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon with Animation
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CheckmarkPainter(_checkAnimation.value),
                        child: Icon(
                          widget.icon ?? LucideIcons.check,
                          size: 40,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // Title
          Text(
            widget.title,
            style: ShadTheme.of(context).textTheme.h4?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spaceMD),

          // Message
          Text(
            widget.message,
            style: ShadTheme.of(context).textTheme.p?.copyWith(
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // Close Button
          if (!widget.autoClose)
            SizedBox(
              width: double.infinity,
              child: ShadButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClose?.call();
                },
                backgroundColor: Colors.green,
                child: Text(
                  widget.buttonText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ShadTheme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSM),
                Text(
                  'Auto-closing...',
                  style: ShadTheme.of(context).textTheme.small?.copyWith(
                    color: ShadTheme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;

  CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();

    // Define checkmark path
    final point1 = Offset(center.dx - 10, center.dy);
    final point2 = Offset(center.dx - 2, center.dy + 8);
    final point3 = Offset(center.dx + 10, center.dy - 8);

    checkPath.moveTo(point1.dx, point1.dy);
    checkPath.lineTo(point2.dx, point2.dy);
    checkPath.lineTo(point3.dx, point3.dy);

    // Draw only part of the path based on progress
    final pathMetrics = checkPath.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Helper function to show success dialog
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'OK',
  VoidCallback? onClose,
  IconData? icon,
  bool autoClose = false,
  Duration autoCloseDuration = const Duration(seconds: 3),
}) {
  return showShadDialog(
    context: context,
    builder: (context) => SuccessDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      onClose: onClose,
      icon: icon,
      autoClose: autoClose,
      autoCloseDuration: autoCloseDuration,
    ),
  );
}
