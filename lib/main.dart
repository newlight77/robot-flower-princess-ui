import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'configurator/theme/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
// import 'presentation/providers/game_mock_provider.dart' as mock;
// import 'presentation/providers/game_provider.dart' as real;
// import 'domain/use_cases/create_game_impl.dart';
// import 'domain/use_cases/get_games_impl.dart';
// import 'domain/use_cases/get_game_impl.dart';
// import 'domain/use_cases/execute_action_impl.dart';
// import 'domain/use_cases/auto_play_impl.dart';
// import 'domain/use_cases/replay_game_impl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
  // runApp(
  //   ProviderScope(
  //     overrides: [
  //       // Override the real providers with mock ones
  //       real.createGameUseCaseProvider.overrideWith((ref) => CreateGameImpl(ref.watch(mock.gameMockRepositoryProvider))),
  //       real.getGamesUseCaseProvider.overrideWith((ref) => GetGamesImpl(ref.watch(mock.gameMockRepositoryProvider))),
  //       real.getGameUseCaseProvider.overrideWith((ref) => GetGameImpl(ref.watch(mock.gameMockRepositoryProvider))),
  //       real.executeActionUseCaseProvider.overrideWith((ref) => ExecuteActionImpl(ref.watch(mock.gameMockRepositoryProvider))),
  //       real.autoPlayUseCaseProvider.overrideWith((ref) => AutoPlayImpl(ref.watch(mock.gameMockRepositoryProvider))),
  //       real.replayGameUseCaseProvider.overrideWith((ref) => ReplayGameImpl(ref.watch(mock.gameMockRepositoryProvider))),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
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
