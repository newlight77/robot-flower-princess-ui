import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../hexagons/game/driven/datasources/game_remote_datasource.dart';
import '../../hexagons/game/driven/repositories/game_repository_impl.dart';
import '../../hexagons/game/domain/ports/outbound/game_repository.dart';
import '../../hexagons/game/domain/use_cases/create_game_impl.dart';
import '../../hexagons/game/domain/use_cases/get_games_impl.dart';
import '../../hexagons/game/domain/use_cases/get_game_impl.dart';
import '../../hexagons/game/domain/use_cases/execute_action_impl.dart';
import '../../hexagons/autoplay/domain/use_cases/auto_play_impl.dart';
import '../../hexagons/game/domain/use_cases/replay_game_impl.dart';

// Infrastructure
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final gameRemoteDataSourceProvider = Provider<GameRemoteDataSource>(
  (ref) => GameRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(ref.watch(gameRemoteDataSourceProvider)),
);

// Use Cases
final createGameUseCaseProvider = Provider(
  (ref) => CreateGameImpl(ref.watch(gameRepositoryProvider)),
);

final getGamesUseCaseProvider = Provider(
  (ref) => GetGamesImpl(ref.watch(gameRepositoryProvider)),
);

final getGameUseCaseProvider = Provider(
  (ref) => GetGameImpl(ref.watch(gameRepositoryProvider)),
);

final executeActionUseCaseProvider = Provider(
  (ref) => ExecuteActionImpl(ref.watch(gameRepositoryProvider)),
);

final autoPlayUseCaseProvider = Provider(
  (ref) => AutoPlayImpl(ref.watch(gameRepositoryProvider)),
);

final replayGameUseCaseProvider = Provider(
  (ref) => ReplayGameImpl(ref.watch(gameRepositoryProvider)),
);
