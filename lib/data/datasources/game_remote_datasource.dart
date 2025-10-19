import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/value_objects/action_type.dart';
import '../../domain/value_objects/direction.dart';
import '../models/game_model.dart';

abstract class GameRemoteDataSource {
  Future<GameModel> createGame(String name, int boardSize);
  Future<List<GameModel>> getGames();
  Future<GameModel> getGame(String gameId);
  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  );
  Future<GameModel> autoPlay(String gameId);
  Future<List<Map<String, dynamic>>> replayGame(String gameId);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final ApiClient client;

  GameRemoteDataSourceImpl(this.client);

  @override
  Future<GameModel> createGame(String name, int boardSize) async {
    try {
      final response = await client.post(
        ApiEndpoints.games,
        data: {
          'name': name,
          'boardSize': boardSize,
        },
      );
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<GameModel>> getGames() async {
    try {
      final response = await client.get(ApiEndpoints.games);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => GameModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GameModel> getGame(String gameId) async {
    try {
      final response = await client.get(ApiEndpoints.game(gameId));
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  ) async {
    try {
      final response = await client.post(
        ApiEndpoints.gameAction(gameId),
        data: {
          'action': action.name,
          'direction': direction.name,
        },
      );
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GameModel> autoPlay(String gameId) async {
    try {
      final response = await client.post(ApiEndpoints.autoPlay(gameId));
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> replayGame(String gameId) async {
    try {
      final response = await client.get(ApiEndpoints.replay(gameId));
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => json as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data?['message'] ?? e.message;

      if (statusCode == 404) {
        return NotFoundException(message);
      } else if (statusCode == 400) {
        return ValidationException(message);
      } else if (statusCode == 500) {
        return ServerException(message);
      }
    }
    return NetworkException(e.message ?? 'Network error occurred');
  }
}
