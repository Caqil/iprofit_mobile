// ============================================================================
// lib/presentation/widgets/dialogs/biometric_dialog.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../data/services/biometric_service.dart';
import '../../../data/models/auth/biometric_config.dart';
import '../../../core/constants/app_constants.dart';

class BiometricDialog extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onCancel;
  final Function(BiometricResult)? onResult;
  final bool showManualOption;

  const BiometricDialog({
    super.key,
    this.title = 'Biometric Authentication',
    this.subtitle = 'Use your biometric to authenticate',
    this.onCancel,
    this.onResult,
    this.showManualOption = false,
  });

  @override
  ConsumerState<BiometricDialog> createState() => _BiometricDialogState();
}

class _BiometricDialogState extends ConsumerState<BiometricDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  BiometricState _currentState = BiometricState.waiting;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initiateBiometric();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initiateBiometric() async {
    setState(() {
      _currentState = BiometricState.authenticating;
      _statusMessage = 'Touch the sensor...';
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final result = await biometricService.authenticate(
        useErrorDialogs: false,
      );

      setState(() {
        if (result.isSuccess) {
          _currentState = BiometricState.success;
          _statusMessage = 'Authentication successful!';
        } else {
          _currentState = BiometricState.failure;
          _statusMessage = result.friendlyMessage;
        }
      });

      widget.onResult?.call(result);

      if (result.isSuccess) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop(result);
        });
      }
    } catch (e) {
      setState(() {
        _currentState = BiometricState.failure;
        _statusMessage = 'Authentication failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375,
      padding: AppConstants.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Biometric Icon with Animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentState == BiometricState.authenticating
                    ? _pulseAnimation.value
                    : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getIconColor(),
                    boxShadow: [
                      BoxShadow(
                        color: _getIconColor().withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(_getIcon(), size: 40, color: Colors.white),
                ),
              );
            },
          ),

          const SizedBox(height: AppConstants.spaceLG),

          // Title
          Text(
            widget.title,
            style: ShadTheme.of(
              context,
            ).textTheme.h4.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Status Message
          Text(
            _statusMessage,
            style: ShadTheme.of(context).textTheme.p.copyWith(
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
                    widget.onCancel?.call();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: AppConstants.spaceMD),

              // Retry or Manual Option
              Expanded(
                child: _currentState == BiometricState.failure
                    ? ShadButton(
                        onPressed: _initiateBiometric,
                        child: const Text('Retry'),
                      )
                    : widget.showManualOption
                    ? ShadButton.outline(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Show manual authentication (PIN/Password)
                        },
                        child: const Text('Use PIN'),
                      )
                    : ShadButton(
                        onPressed: null,
                        child: const Text('Authenticating...'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (_currentState) {
      case BiometricState.success:
        return LucideIcons.circleCheck;
      case BiometricState.failure:
        return LucideIcons.circleX;
      case BiometricState.authenticating:
      case BiometricState.waiting:
      default:
        return LucideIcons.fingerprint;
    }
  }

  Color _getIconColor() {
    switch (_currentState) {
      case BiometricState.success:
        return Colors.green;
      case BiometricState.failure:
        return Colors.red;
      case BiometricState.authenticating:
      case BiometricState.waiting:
      default:
        return ShadTheme.of(context).colorScheme.primary;
    }
  }
}

// Helper function to show biometric dialog
Future<BiometricResult?> showBiometricDialog(
  BuildContext context, {
  String title = 'Biometric Authentication',
  String subtitle = 'Use your biometric to authenticate',
  bool showManualOption = false,
}) {
  return showShadDialog<BiometricResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BiometricDialog(
      title: title,
      subtitle: subtitle,
      showManualOption: showManualOption,
    ),
  );
}
