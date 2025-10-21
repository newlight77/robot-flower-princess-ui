import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/game_mock_datasource.dart';
import '../../data/repositories/game_mock_repository.dart';
import '../../domain/ports/outbound/game_repository.dart';
import '../../domain/use_cases/create_game_impl.dart';
import '../../domain/use_cases/get_games_impl.dart';
import '../../domain/use_cases/get_game_impl.dart';
import '../../domain/use_cases/execute_action_impl.dart';
import '../../domain/use_cases/auto_play_impl.dart';
import '../../domain/use_cases/replay_game_impl.dart';

// Mock Infrastructure
final gameMockDataSourceProvider = Provider<GameMockDataSource>(
  (ref) => GameMockDataSource(),
);

final gameMockRepositoryProvider = Provider<GameRepository>(
  (ref) => GameMockRepository(ref.watch(gameMockDataSourceProvider)),
);

// Mock Use Cases
final createGameUseCaseProvider = Provider(
  (ref) => CreateGameImpl(ref.watch(gameMockRepositoryProvider)),
);

final getGamesUseCaseProvider = Provider(
  (ref) => GetGamesImpl(ref.watch(gameMockRepositoryProvider)),
);

final getGameUseCaseProvider = Provider(
  (ref) => GetGameImpl(ref.watch(gameMockRepositoryProvider)),
);

final executeActionUseCaseProvider = Provider(
  (ref) => ExecuteActionImpl(ref.watch(gameMockRepositoryProvider)),
);

final autoPlayUseCaseProvider = Provider(
  (ref) => AutoPlayImpl(ref.watch(gameMockRepositoryProvider)),
);

final replayGameUseCaseProvider = Provider(
  (ref) => ReplayGameImpl(ref.watch(gameMockRepositoryProvider)),
);
