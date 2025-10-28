#!/usr/bin/env python3
"""
Robot Flower Princess - Part 4: Game Page & Main App
Generates the main application, pages, and navigation
"""

import os
import zipfile
from pathlib import Path

def generate_files(base_path):
    """Generate all application and page files"""

    files = {
        # Main App
        'lib/main.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home/home_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Flower Princess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
''',

        # Home Page
        'lib/presentation/pages/home/home_page.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/games_list_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/current_game_provider.dart';
import 'widgets/create_game_dialog.dart';
import 'widgets/game_list_item.dart';
import '../game/game_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gamesListProvider.notifier).loadGames());
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Robot Flower Princess'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(gamesListProvider.notifier).loadGames(),
          ),
        ],
      ),
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return _buildEmptyState();
          }
          return _buildGamesList(games);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGameDialog(context),
        backgroundColor: AppColors.forestGreen,
        icon: const Icon(Icons.add),
        label: const Text('New Game'),
      ),
    );
  }

  Widget _buildGamesList(List games) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(gamesListProvider.notifier).loadGames();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return GameListItem(
            game: game,
            onTap: () => _navigateToGame(game.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.games_outlined,
            size: 100,
            color: AppColors.mossGreen,
          ),
          const SizedBox(height: 24),
          const Text(
            'No games yet!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new game to start playing',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 100,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(gamesListProvider.notifier).loadGames(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCreateGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateGameDialog(
        onGameCreated: (game) {
          ref.read(gamesListProvider.notifier).addGame(game);
          _navigateToGame(game.id);
        },
      ),
    );
  }

  void _navigateToGame(String gameId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(gameId: gameId),
      ),
    );
  }
}
''',

        'lib/presentation/pages/home/widgets/create_game_dialog.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/game.dart';
import '../../../providers/game_provider.dart';

class CreateGameDialog extends ConsumerStatefulWidget {
  final Function(Game) onGameCreated;

  const CreateGameDialog({
    super.key,
    required this.onGameCreated,
  });

  @override
  ConsumerState<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends ConsumerState<CreateGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _boardSize = AppConstants.defaultBoardSize;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎮 Create New Game'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Game Name',
                hintText: 'Enter a name for your game',
                prefixIcon: Icon(Icons.games),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a game name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Board Size: $_boardSize x $_boardSize',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Slider(
              value: _boardSize.toDouble(),
              min: AppConstants.minBoardSize.toDouble(),
              max: AppConstants.maxBoardSize.toDouble(),
              divisions: AppConstants.maxBoardSize - AppConstants.minBoardSize,
              label: '$_boardSize',
              onChanged: (value) {
                setState(() {
                  _boardSize = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createGame,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final createGameUseCase = ref.read(createGameUseCaseProvider);
    final result = await createGameUseCase(_nameController.text, _boardSize);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (game) {
        Navigator.pop(context);
        widget.onGameCreated(game);
      },
    );
  }
}
''',

        'lib/presentation/pages/home/widgets/game_list_item.dart': '''import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/game.dart';
import '../../../widgets/game_status_badge.dart';

class GameListItem extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameListItem({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.forestGreen,
          child: Text(
            '${game.board.width}x${game.board.height}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          game.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Flowers: ${game.board.flowersDelivered}/${game.board.totalFlowers} • '
          'Actions: ${game.actions.length}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameStatusBadge(status: game.status),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
''',

        # Game Page
        'lib/presentation/pages/game/game_page.dart': '''import 'package:flutter/material.dart';
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
    super.key,
    required this.gameId,
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
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(currentGameProvider.notifier).loadGame(widget.gameId);
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
              color: AppColors.error.withOpacity(0.1),
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
''',

        'lib/presentation/pages/game/widgets/action_controls.dart': '''import 'package:flutter/material.dart';
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
    super.key,
    required this.selectedDirection,
    required this.onDirectionSelected,
    required this.onActionPressed,
    required this.onAutoPlay,
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
''',

        'lib/presentation/pages/game/widgets/replay_dialog.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/game_board.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/game_board_widget.dart';

class ReplayDialog extends ConsumerStatefulWidget {
  final String gameId;

  const ReplayDialog({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<ReplayDialog> createState() => _ReplayDialogState();
}

class _ReplayDialogState extends ConsumerState<ReplayDialog> {
  List<GameBoard>? _boardStates;
  int _currentStep = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReplay();
  }

  Future<void> _loadReplay() async {
    final replayUseCase = ref.read(replayGameUseCaseProvider);
    final result = await replayUseCase(widget.gameId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (boards) {
        setState(() {
          _boardStates = boards;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            if (_boardStates != null) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_outline, color: Colors.white),
          const SizedBox(width: 12),
          const Text(
            'Game Replay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_boardStates == null || _boardStates!.isEmpty) {
      return const Center(
        child: Text('No replay data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GameBoardWidget(
        board: _boardStates![_currentStep],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Text(
            'Step ${_currentStep + 1} / ${_boardStates!.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _currentStep.toDouble(),
            min: 0,
            max: (_boardStates!.length - 1).toDouble(),
            divisions: _boardStates!.length - 1,
            onChanged: (value) {
              setState(() {
                _currentStep = value.toInt();
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _currentStep > 0
                    ? () => setState(() => _currentStep = 0)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentStep > 0
                    ? () => setState(() => _currentStep--)
                    : null,
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 36,
                onPressed: _togglePlayback,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentStep < _boardStates!.length - 1
                    ? () => setState(() => _currentStep++)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _currentStep < _boardStates!.length - 1
                    ? () => setState(() => _currentStep = _boardStates!.length - 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _playReplay();
    }
  }

  Future<void> _playReplay() async {
    while (_isPlaying && _currentStep < _boardStates!.length - 1) {
      await Future.delayed(AppConstants.replayStepDuration);
      if (!mounted || !_isPlaying) break;
      setState(() => _currentStep++);
    }
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }
}
''',

        # Widget Tests
        'test/widget/game_board_widget_test.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robot_flower_princess_front/domain/entities/game_board.dart';
import 'package:robot_flower_princess_front/domain/entities/robot.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';
import 'package:robot_flower_princess_front/domain/value_objects/position.dart';
import 'package:robot_flower_princess_front/presentation/widgets/game_board_widget.dart';

void main() {
  testWidgets('GameBoardWidget displays board correctly', (tester) async {
    const testBoard = GameBoard(
      width: 5,
      height: 5,
      cells: [],
      robot: Robot(
        position: Position(x: 0, y: 0),
        orientation: Direction.NORTH,
      ),
      princessPosition: Position(x: 4, y: 4),
      totalFlowers: 3,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameBoardWidget(board: testBoard),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('🤖'), findsOneWidget);
    expect(find.text('👑'), findsOneWidget);
  });
}
''',
    }

    for file_path, content in files.items():
        full_path = os.path.join(base_path, file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)

def main():
    """Main function to generate Part 4"""
    base_path = 'robot-flower-princess-front'

    print("🚀 Generating Part 4: Game Page & Main App...")

    # Generate files
    generate_files(base_path)
    print("✅ Game pages and main app generated")

    # Create zip file
    zip_filename = 'robot-flower-princess-part4.zip'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(base_path):
            if 'lib/main.dart' in root or 'pages' in root or 'test/widget' in root:
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, os.path.dirname(base_path))
                    zipf.write(file_path, arcname)

    print(f"✅ Part 4 packaged as {zip_filename}")
    print("\n📦 Part 4 Complete!")
    print("   - Main app created")
    print("   - Home page with game list")
    print("   - Create game dialog")
    print("   - Game page with controls")
    print("   - Replay functionality")
    print("   - Widget tests added")

if __name__ == '__main__':
    main()