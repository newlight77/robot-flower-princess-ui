import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/value_objects/game_status.dart';

class GameStatusBadge extends StatelessWidget {
  final GameStatus status;

  const GameStatusBadge({
    required this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    switch (status) {
      case GameStatus.playing:
        backgroundColor = AppColors.info;
        break;
      case GameStatus.won:
        backgroundColor = AppColors.success;
        break;
      case GameStatus.gameOver:
        backgroundColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
