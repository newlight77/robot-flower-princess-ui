import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/value_objects/direction.dart';

class DirectionSelector extends StatelessWidget {
  final Direction? selectedDirection;
  final ValueChanged<Direction> onDirectionSelected;

  const DirectionSelector({
    required this.selectedDirection, required this.onDirectionSelected, super.key,
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
            _buildDirectionButton(Direction.north),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.east),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.south),
            const SizedBox(width: 8),
            _buildDirectionButton(Direction.west),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(Direction direction) {
    final isSelected = selectedDirection == direction;

    return ElevatedButton(
      onPressed: () => onDirectionSelected(direction),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.warmOrange : AppColors.mossGreen,
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
