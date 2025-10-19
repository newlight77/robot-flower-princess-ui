import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game.dart';
import 'game_provider.dart';

class GamesListNotifier extends StateNotifier<AsyncValue<List<Game>>> {
  GamesListNotifier(this._getGamesUseCase) : super(const AsyncValue.loading());

  final dynamic _getGamesUseCase;

  Future<void> loadGames() async {
    state = const AsyncValue.loading();
    final result = await _getGamesUseCase();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (games) => state = AsyncValue.data(games),
    );
  }

  void addGame(Game game) {
    state.whenData((games) {
      state = AsyncValue.data([game, ...games]);
    });
  }
}

final gamesListProvider =
    StateNotifierProvider<GamesListNotifier, AsyncValue<List<Game>>>((ref) {
  return GamesListNotifier(ref.watch(getGamesUseCaseProvider));
});
