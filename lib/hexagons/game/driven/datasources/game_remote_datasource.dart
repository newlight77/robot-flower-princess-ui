import 'package:dio/dio.dart';
import '../../../../configurator/constants/api_endpoints.dart';
import '../../../../shared/error/exceptions.dart';
import '../../../../shared/client/api_client.dart';
import '../../../../shared/util/logger.dart';
import '../../domain/value_objects/action_type.dart';
import '../../../autoplay/domain/value_objects/auto_play_strategy.dart';
import '../../domain/value_objects/direction.dart';
import '../models/game_model.dart';

abstract class GameRemoteDataSource {
  Future<GameModel> createGame(String name, int boardSize);
  Future<List<GameModel>> getGames({int limit = 10, String? status});
  Future<GameModel> getGame(String gameId);
  Future<GameModel> executeAction(
    String gameId,
    ActionType action,
    Direction direction,
  );
  Future<GameModel> autoPlay(
    String gameId, {
    AutoPlayStrategy strategy = AutoPlayStrategy.greedy,
  });
  Future<Map<String, dynamic>> getGameHistory(String gameId);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final ApiClient client;

  GameRemoteDataSourceImpl(this.client);

  @override
  Future<GameModel> createGame(String name, int boardSize) async {
    try {
      final requestData = {
        'name': name,
        'cols': boardSize,
        'rows': boardSize,
      };

      Logger.info('Creating game with data: $requestData');

      final response = await client.post(
        ApiEndpoints.games,
        data: requestData,
      );

      Logger.info('Create game response status: ${response.statusCode}');
      Logger.info('Create game response headers: ${response.headers}');
      Logger.info(
          'Create game response data type: ${response.data.runtimeType}');
      Logger.info('Create game response data: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        Logger.error(
            'Response data is not a Map<String, dynamic>, it is: ${response.data.runtimeType}');
        throw Exception(
            'Expected Map<String, dynamic> but got ${response.data.runtimeType}');
      }

      // Some backends wrap the created game under a 'game' property
      final responseMap = response.data as Map<String, dynamic>;
      final gameJson = responseMap['game'] is Map<String, dynamic>
          ? responseMap['game'] as Map<String, dynamic>
          : responseMap;

      return GameModel.fromJson(gameJson);
    } on DioException catch (e) {
      Logger.error('Create game error: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<GameModel>> getGames({int limit = 10, String? status}) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await client.get(
        ApiEndpoints.games,
        queryParameters: queryParams,
      );

      // Debug logging to understand response structure
      Logger.info('getGames response type: ${response.data.runtimeType}');
      Logger.info('getGames response data: ${response.data}');

      // Handle different response formats
      List<dynamic> data;
      if (response.data is List) {
        // Direct array format
        Logger.info('Processing direct array format');
        data = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        // Wrapped in object format - check common property names
        Logger.info('Processing wrapped object format');
        final responseMap = response.data as Map<String, dynamic>;
        Logger.info('Response map keys: ${responseMap.keys.toList()}');

        if (responseMap.containsKey('games')) {
          data = responseMap['games'] as List<dynamic>;
        } else if (responseMap.containsKey('gamess')) {
          // Note: API has typo 'gamess' instead of 'games'
          data = responseMap['gamess'] as List<dynamic>;
        } else if (responseMap.containsKey('data')) {
          data = responseMap['data'] as List<dynamic>;
        } else if (responseMap.containsKey('items')) {
          data = responseMap['items'] as List<dynamic>;
        } else {
          // If it's a single game object, wrap it in a list
          Logger.info('Treating response as single game object');
          data = [responseMap];
        }
      } else {
        throw Exception(
            'Unexpected response format: ${response.data.runtimeType}');
      }

      Logger.info('Final data length: ${data.length}');
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
  Future<GameModel> autoPlay(
    String gameId, {
    AutoPlayStrategy strategy = AutoPlayStrategy.greedy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      // Only include strategy if it's not the default (greedy)
      if (strategy != AutoPlayStrategy.greedy) {
        queryParams['strategy'] = strategy.toApiParam();
      }

      final response = await client.post(
        ApiEndpoints.autoPlay(gameId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return GameModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getGameHistory(String gameId) async {
    try {
      final response = await client.get(ApiEndpoints.gameHistory(gameId));
      Logger.info('getGameHistory response: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        throw Exception(
            'Expected Map<String, dynamic> but got ${response.data.runtimeType}');
      }

      return response.data as Map<String, dynamic>;
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
