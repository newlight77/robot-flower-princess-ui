import 'package:flutter/material.dart';
import '../../../../domain/value_objects/action_type.dart';
import '../../../../domain/value_objects/direction.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/direction_selector.dart';

class ActionControls extends StatelessWidget {
  final Direction? selectedDirection;
  final ValueChanged<Direction> onDirectionSelected;
  final Function(ActionType) onActionPressed;
  final VoidCallback onAutoPlay;
  final bool isGameFinished;

  const ActionControls({
    required this.selectedDirection,
    required this.onDirectionSelected,
    required this.onActionPressed,
    required this.onAutoPlay,
    super.key,
    this.isGameFinished = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DirectionSelector(
              selectedDirection: selectedDirection,
              onDirectionSelected: onDirectionSelected,
              isEnabled: !isGameFinished,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ActionButton(
                  actionType: ActionType.rotate,
                  onPressed: () => onActionPressed(ActionType.rotate),
                  isEnabled: !isGameFinished && selectedDirection != null,
                ),
                ActionButton(
                  actionType: ActionType.move,
                  onPressed: () => onActionPressed(ActionType.move),
                  isEnabled: !isGameFinished && selectedDirection != null,
                ),
                ActionButton(
                  actionType: ActionType.pickFlower,
                  onPressed: () => onActionPressed(ActionType.pickFlower),
                  isEnabled: !isGameFinished && selectedDirection != null,
                ),
                ActionButton(
                  actionType: ActionType.dropFlower,
                  onPressed: () => onActionPressed(ActionType.dropFlower),
                  isEnabled: !isGameFinished && selectedDirection != null,
                ),
                ActionButton(
                  actionType: ActionType.giveFlower,
                  onPressed: () => onActionPressed(ActionType.giveFlower),
                  isEnabled: !isGameFinished && selectedDirection != null,
                ),
                ActionButton(
                  actionType: ActionType.clean,
                  onPressed: () => onActionPressed(ActionType.clean),
                  isEnabled: !isGameFinished && selectedDirection != null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isGameFinished ? null : onAutoPlay,
                icon: const Icon(Icons.smart_toy),
                label: const Text('Auto Play'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
