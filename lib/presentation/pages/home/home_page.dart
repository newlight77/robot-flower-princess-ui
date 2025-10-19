import 'package:flutter/material.dart';
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
