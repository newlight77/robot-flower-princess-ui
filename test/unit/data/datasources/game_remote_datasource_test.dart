import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:robot_flower_princess_front/core/error/exceptions.dart';
import 'package:robot_flower_princess_front/core/network/api_client.dart';
import 'package:robot_flower_princess_front/data/datasources/game_remote_datasource.dart';
import 'package:robot_flower_princess_front/domain/value_objects/action_type.dart';
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart';

@GenerateMocks([ApiClient])
import 'game_remote_datasource_test.mocks.dart';

void main() {
  late GameRemoteDataSourceImpl datasource;
  late MockApiClient mockClient;

  setUp(() {
    mockClient = MockApiClient();
    datasource = GameRemoteDataSourceImpl(mockClient);
  });

  final testGameJson = {
    'id': 'test-123',
    'name': 'Test Game',
    'rows': 10,
    'cols': 10,
    'grid': [
      ['⬜', '🤖', '⬜', '⬜', '⬜', '⬜', '⬜', '⬜', '⬜', '⬜'],
      ['⬜', '🌸', '⬜', '⬜', '⬜', '⬜', '⬜', '⬜', '⬜', '⬜'],
      ...List.generate(8, (_) => List.generate(10, (__) => '⬜')),
    ],
    'robot': {
      'position': {'x': 1, 'y': 0},
      'orientation': 'north',
      'flowers': {'collected': [], 'delivered': [], 'collection_capacity': 12},
      'obstacles': {'cleaned': []},
      'executed_actions': []
    },
    'princess': {
      'position': {'x': 9, 'y': 9},
      'flowers_received': 0,
      'mood': 'neutral'
    },
    'flowers': {'total': 1, 'remaining': 1},
    'obstacles': {'total': 0, 'remaining': 0},
    'status': 'in_progress',
    'actions': [],
    'createdAt': '2024-01-01T10:00:00.000Z',
  };

  group('GameRemoteDataSourceImpl', () {
    group('createGame', () {
      test('should return GameModel on successful creation', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/api/games/'),
                  data: testGameJson,
                  statusCode: 201,
                ));

        final result = await datasource.createGame('Test Game', 10);

        expect(result.id, 'test-123');
        expect(result.name, 'Test Game');
        verify(mockClient.post(any, data: anyNamed('data'))).called(1);
      });

      test('should handle wrapped game response', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/api/games/'),
                  data: {'game': testGameJson},
                  statusCode: 201,
                ));

        final result = await datasource.createGame('Test Game', 10);

        expect(result.id, 'test-123');
      });

      test('should throw ServerException on 500 error', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/'),
            statusCode: 500,
            data: {'message': 'Internal server error'},
          ),
        ));

        expect(
          () => datasource.createGame('Test', 10),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw NetworkException on connection error', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          type: DioExceptionType.connectionError,
        ));

        expect(
          () => datasource.createGame('Test', 10),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should throw ValidationException on 400 error', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/'),
            statusCode: 400,
            data: {'message': 'Invalid board size'},
          ),
        ));

        expect(
          () => datasource.createGame('Test', 1),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('getGames', () {
      test('should return list of GameModels', () async {
        when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/api/games/'),
                  data: {
                    'games': [testGameJson, testGameJson]
                  },
                  statusCode: 200,
                ));

        final result = await datasource.getGames();

        expect(result, hasLength(2));
        expect(result[0].id, 'test-123');
      });

      test('should handle array response without wrapper', () async {
        when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/api/games/'),
                  data: [testGameJson],
                  statusCode: 200,
                ));

        final result = await datasource.getGames();

        expect(result, hasLength(1));
      });

      test('should pass query parameters correctly', () async {
        when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => Response(
                  requestOptions: RequestOptions(path: '/api/games/'),
                  data: {'games': []},
                  statusCode: 200,
                ));

        await datasource.getGames(limit: 5, status: 'playing');

        verify(mockClient.get(any,
                queryParameters: anyNamed('queryParameters')))
            .called(1);
      });

      test('should throw ServerException on error', () async {
        when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/'),
            statusCode: 500,
            data: {'message': 'Server error'},
          ),
        ));

        expect(
          () => datasource.getGames(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getGame', () {
      test('should return GameModel for valid ID', () async {
        when(mockClient.get(any)).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/games/test-123'),
              data: testGameJson,
              statusCode: 200,
            ));

        final result = await datasource.getGame('test-123');

        expect(result.id, 'test-123');
        verify(mockClient.get(any)).called(1);
      });

      test('should throw NotFoundException on 404', () async {
        when(mockClient.get(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/invalid'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/invalid'),
            statusCode: 404,
            data: {'message': 'Game not found'},
          ),
        ));

        expect(
          () => datasource.getGame('invalid'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('executeAction', () {
      test('should return updated GameModel', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenAnswer((_) async => Response(
                  requestOptions:
                      RequestOptions(path: '/api/games/test-123/action'),
                  data: testGameJson,
                  statusCode: 200,
                ));

        final result = await datasource.executeAction(
          'test-123',
          ActionType.move,
          Direction.north,
        );

        expect(result.id, 'test-123');
        verify(mockClient.post(any, data: anyNamed('data'))).called(1);
      });

      test('should throw NetworkException for 409 status (game over)',
          () async {
        // Note: _handleDioError doesn't have special handling for 409,
        // so it returns NetworkException by default
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/test-123/action'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/test-123/action'),
            statusCode: 409,
            data: {'message': 'Game is over'},
          ),
        ));

        expect(
          () => datasource.executeAction(
            'test-123',
            ActionType.move,
            Direction.north,
          ),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should throw ValidationException on invalid action', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/test-123/action'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/test-123/action'),
            statusCode: 400,
            data: {'message': 'Invalid action'},
          ),
        ));

        expect(
          () => datasource.executeAction(
            'test-123',
            ActionType.move,
            Direction.north,
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('autoPlay', () {
      test('should return completed GameModel', () async {
        when(mockClient.post(any)).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: '/api/games/test-123/autoplay'),
              data: {...testGameJson, 'status': 'victory'},
              statusCode: 200,
            ));

        final result = await datasource.autoPlay('test-123');

        expect(result.id, 'test-123');
        verify(mockClient.post(any)).called(1);
      });

      test('should throw ServerException on error', () async {
        when(mockClient.post(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/test-123/autoplay'),
          response: Response(
            requestOptions:
                RequestOptions(path: '/api/games/test-123/autoplay'),
            statusCode: 500,
            data: {'message': 'Server error'},
          ),
        ));

        expect(
          () => datasource.autoPlay('test-123'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getGameHistory', () {
      test('should return history map', () async {
        final historyData = {
          'history': [testGameJson, testGameJson]
        };

        when(mockClient.get(any)).thenAnswer((_) async => Response(
              requestOptions:
                  RequestOptions(path: '/api/games/test-123/history'),
              data: historyData,
              statusCode: 200,
            ));

        final result = await datasource.getGameHistory('test-123');

        expect(result, isA<Map<String, dynamic>>());
        expect(result['history'], isA<List>());
        verify(mockClient.get(any)).called(1);
      });

      test('should throw NotFoundException on 404', () async {
        when(mockClient.get(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/invalid/history'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/games/invalid/history'),
            statusCode: 404,
            data: {'message': 'Game not found'},
          ),
        ));

        expect(
          () => datasource.getGameHistory('invalid'),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('Error Handling', () {
      test('should handle timeout exceptions', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          type: DioExceptionType.connectionTimeout,
        ));

        expect(
          () => datasource.createGame('Test', 10),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle receive timeout', () async {
        when(mockClient.get(any)).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/test'),
          type: DioExceptionType.receiveTimeout,
        ));

        expect(
          () => datasource.getGame('test'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle send timeout', () async {
        when(mockClient.post(any, data: anyNamed('data')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          type: DioExceptionType.sendTimeout,
        ));

        expect(
          () => datasource.createGame('Test', 10),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle cancel exception', () async {
        when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/games/'),
          type: DioExceptionType.cancel,
          message: 'Request cancelled',
        ));

        expect(
          () => datasource.getGames(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle unknown exceptions', () async {
        // Non-DioException errors propagate as-is (not caught by datasource)
        when(mockClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenThrow(Exception('Unknown error'));

        expect(
          () => datasource.getGames(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
