import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/value_objects/action_type.dart';
import '../../../domain/value_objects/direction.dart';
import '../../providers/current_game_provider.dart';
import '../../widgets/game_board_widget.dart';
import '../../widgets/game_info_panel.dart';
import 'widgets/action_controls.dart';
import 'widgets/replay_dialog.dart';

class GamePage extends ConsumerStatefulWidget {
  final String gameId;

  const GamePage({
    required this.gameId,
    super.key,
  });

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  Direction? _selectedDirection;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(currentGameProvider.notifier).loadGame(widget.gameId);
    });
  }

  @override
  void dispose() {
    ref.read(currentGameProvider.notifier).clearGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(currentGameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(currentGameProvider.notifier).loadGame(widget.gameId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _showReplayDialog,
          ),
        ],
      ),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 900;

              if (isWideScreen) {
                return _buildWideLayout(game);
              } else {
                return _buildNarrowLayout(game);
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(currentGameProvider.notifier)
                        .loadGame(widget.gameId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(game) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GameBoardWidget(board: game.board),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GameInfoPanel(game: game),
                const SizedBox(height: 16),
                _buildControls(game),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(game) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GameInfoPanel(game: game),
          ),
          SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GameBoardWidget(board: game.board),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildControls(game),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(game) {
    return Column(
      children: [
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _errorMessage = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ActionControls(
          selectedDirection: _selectedDirection,
          onDirectionSelected: (direction) {
            setState(() {
              _selectedDirection = direction;
              _errorMessage = null;
            });
          },
          onActionPressed: (action) => _executeAction(action, game),
          onAutoPlay: _autoPlay,
          isGameFinished: game.status.isFinished,
        ),
      ],
    );
  }

  Future<void> _executeAction(ActionType action, game) async {
    if (_selectedDirection == null) {
      setState(() {
        _errorMessage = 'Please select a direction first';
      });
      return;
    }

    if (game.status.isFinished) {
      setState(() {
        _errorMessage = 'Game is already finished';
      });
      return;
    }

    await ref
        .read(currentGameProvider.notifier)
        .executeAction(action, _selectedDirection!);

    final newGameAsync = ref.read(currentGameProvider);
    newGameAsync.whenOrNull(
      error: (error, stack) {
        setState(() {
          _errorMessage = error.toString();
        });
      },
    );
  }

  Future<void> _autoPlay() async {
    final game = ref.read(currentGameProvider).value;
    if (game == null || game.status.isFinished) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Play'),
        content: const Text(
          'Let the AI try to solve the game automatically?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(currentGameProvider.notifier).autoPlay();
    }
  }

  void _showReplayDialog() {
    showDialog(
      context: context,
      builder: (context) => ReplayDialog(gameId: widget.gameId),
    );
  }
}
