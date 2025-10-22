import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/game_board.dart';
import '../../domain/entities/cell.dart';
import '../../domain/value_objects/cell_type.dart';
import '../../domain/value_objects/position.dart';

class GameBoardWidget extends StatelessWidget {
  final GameBoard board;
  final double cellSize;

  const GameBoardWidget({
    required this.board,
    super.key,
    this.cellSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size based on available width, ensuring minimum size
        final availableWidth = constraints.maxWidth - 32; // Account for padding
        final calculatedCellSize = (availableWidth / board.width).clamp(30.0, 80.0);
        final boardWidth = calculatedCellSize * board.width;
        final boardHeight = calculatedCellSize * board.height;

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Container(
                width: boardWidth,
                height: boardHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.forestGreen, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: board.width,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: board.width * board.height,
                  itemBuilder: (context, index) {
                    final x = index % board.width;
                    final y = index ~/ board.width;
                    final position = Position(x: x, y: y);
                    final cell = board.getCellAt(position);

                    return _buildCell(context, cell, position);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildCell(BuildContext context, Cell? cell, Position position) {
    final isRobotHere = board.robot.position == position;
    final isPrincessHere = board.princess.position == position;

    Color backgroundColor = AppColors.emptyCell;
    String icon = CellType.empty.icon;

    if (isRobotHere) {
      backgroundColor = AppColors.robotBlue.withValues(alpha: 0.3);
      icon = '🤖';
    } else if (isPrincessHere) {
      backgroundColor = AppColors.princessPink.withValues(alpha: 0.3);
      icon = '👑';
    } else if (cell != null) {
      switch (cell.type) {
        case CellType.flower:
          backgroundColor = AppColors.flowerPink.withValues(alpha: 0.3);
          icon = '🌸';
          break;
        case CellType.obstacle:
          backgroundColor = AppColors.obstacleGray.withValues(alpha: 0.3);
          icon = '🗑️';
          break;
        default:
          break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: AppColors.mossGreen.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
