import 'package:flutter/material.dart';
import '../../configurator/theme/app_colors.dart';
import '../../hexagons/game/domain/value_objects/action_type.dart';

class ActionButton extends StatelessWidget {
  final ActionType actionType;
  final VoidCallback onPressed;
  final bool isEnabled;

  const ActionButton({
    required this.actionType,
    required this.onPressed,
    super.key,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: actionType.displayName,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.forestGreen : AppColors.obstacleGray,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              actionType.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              actionType.displayName.split(' ').last,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
