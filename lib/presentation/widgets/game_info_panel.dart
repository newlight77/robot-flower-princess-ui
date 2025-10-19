import 'package:flutter/material.dart';
import '../../domain/entities/game.dart';
import 'game_status_badge.dart';

class GameInfoPanel extends StatelessWidget {
  final Game game;

  const GameInfoPanel({
    required this.game, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GameStatusBadge(status: game.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '🤖 Robot Position',
              '(${game.board.robot.position.x}, ${game.board.robot.position.y})',
            ),
            _buildInfoRow(
              '🌸 Flowers Held',
              '${game.board.robot.flowersHeld}/12',
            ),
            _buildInfoRow(
              '📦 Total Flowers',
              '${game.board.totalFlowers}',
            ),
            _buildInfoRow(
              '✅ Flowers Delivered',
              '${game.board.flowersDelivered}',
            ),
            _buildInfoRow(
              '⏱️ Actions Taken',
              '${game.actions.length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
