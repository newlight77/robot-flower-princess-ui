import 'package:flutter/material.dart';
import '../../configurator/theme/app_colors.dart';
import '../../hexagons/game/domain/value_objects/direction.dart';

class DirectionSelector extends StatelessWidget {
  final Direction? selectedDirection;
  final ValueChanged<Direction> onDirectionSelected;
  final bool isEnabled;

  const DirectionSelector({
    required this.selectedDirection,
    required this.onDirectionSelected,
    super.key,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select Direction',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDirectionButton(Direction.NORTH),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.EAST),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.SOUTH),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.WEST),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(Direction direction) {
    final isSelected = selectedDirection == direction;

    return ElevatedButton(
      onPressed: isEnabled ? () => onDirectionSelected(direction) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.warmOrange : AppColors.mossGreen,
        padding: const EdgeInsets.all(12),
        shape: const CircleBorder(),
      ),
      child: Text(
        direction.icon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
