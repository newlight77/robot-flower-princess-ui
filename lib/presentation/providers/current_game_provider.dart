import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/game.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import 'game_provider.dart';

class CurrentGameNotifier extends StateNotifier<AsyncValue<Game?>> {
  CurrentGameNotifier(
    this._getGameUseCase,
    this._executeActionUseCase,
    this._autoPlayUseCase,
  ) : super(const AsyncValue.data(null));

  final dynamic _getGameUseCase;
  final dynamic _executeActionUseCase;
  final dynamic _autoPlayUseCase;

  Future<void> loadGame(String gameId) async {
    state = const AsyncValue.loading();
    final result = await _getGameUseCase(gameId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (game) => state = AsyncValue.data(game),
    );
  }

  Future<void> executeAction(ActionType action, Direction direction) async {
    final currentGame = state.value;
    if (currentGame == null) return;

    state = const AsyncValue.loading();
    final result = await _executeActionUseCase(currentGame.id, action, direction);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (game) => state = AsyncValue.data(game),
    );
  }

  Future<void> autoPlay() async {
    final currentGame = state.value;
    if (currentGame == null) return;

    state = const AsyncValue.loading();
    final result = await _autoPlayUseCase(currentGame.id);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (game) => state = AsyncValue.data(game),
    );
  }

  void clearGame() {
    state = const AsyncValue.data(null);
  }
}

final currentGameProvider =
    StateNotifierProvider<CurrentGameNotifier, AsyncValue<Game?>>((ref) {
  return CurrentGameNotifier(
    ref.watch(getGameUseCaseProvider),
    ref.watch(executeActionUseCaseProvider),
    ref.watch(autoPlayUseCaseProvider),
  );
});
