// Mocks generated for GameRepositoryImpl tests
// ignore_for_file: no_leading_underscores_for_library_prefixes, type=lint
// ignore_for_file: avoid_redundant_argument_values, avoid_setters_without_getters
// ignore_for_file: comment_references, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports, invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable, prefer_const_constructors, unnecessary_parenthesis
// ignore_for_file: camel_case_types, subtype_of_sealed_class

import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:robot_flower_princess_front/data/datasources/game_remote_datasource.dart'
    as _i2;
import 'package:robot_flower_princess_front/data/models/game_model.dart' as _i4;
import 'package:robot_flower_princess_front/domain/value_objects/action_type.dart'
    as _i5;
import 'package:robot_flower_princess_front/domain/value_objects/direction.dart'
    as _i6;

/// A class which mocks [GameRemoteDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockGameRemoteDataSource extends _i1.Mock
    implements _i2.GameRemoteDataSource {
  MockGameRemoteDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i4.GameModel> createGame(
    String? name,
    int? boardSize,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createGame,
          [
            name,
            boardSize,
          ],
        ),
        returnValue: _i3.Future<_i4.GameModel>.value(_FakeGameModel_0(
          this,
          Invocation.method(
            #createGame,
            [
              name,
              boardSize,
            ],
          ),
        )),
      ) as _i3.Future<_i4.GameModel>);

  @override
  _i3.Future<List<_i4.GameModel>> getGames({
    int? limit,
    String? status,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getGames,
          [],
          {
            #limit: limit,
            #status: status,
          },
        ),
        returnValue: _i3.Future<List<_i4.GameModel>>.value(<_i4.GameModel>[]),
      ) as _i3.Future<List<_i4.GameModel>>);

  @override
  _i3.Future<_i4.GameModel> getGame(String? gameId) => (super.noSuchMethod(
        Invocation.method(
          #getGame,
          [gameId],
        ),
        returnValue: _i3.Future<_i4.GameModel>.value(_FakeGameModel_0(
          this,
          Invocation.method(
            #getGame,
            [gameId],
          ),
        )),
      ) as _i3.Future<_i4.GameModel>);

  @override
  _i3.Future<_i4.GameModel> executeAction(
    String? gameId,
    _i5.ActionType? action,
    _i6.Direction? direction,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #executeAction,
          [
            gameId,
            action,
            direction,
          ],
        ),
        returnValue: _i3.Future<_i4.GameModel>.value(_FakeGameModel_0(
          this,
          Invocation.method(
            #executeAction,
            [
              gameId,
              action,
              direction,
            ],
          ),
        )),
      ) as _i3.Future<_i4.GameModel>);

  @override
  _i3.Future<_i4.GameModel> autoPlay(String? gameId) => (super.noSuchMethod(
        Invocation.method(
          #autoPlay,
          [gameId],
        ),
        returnValue: _i3.Future<_i4.GameModel>.value(_FakeGameModel_0(
          this,
          Invocation.method(
            #autoPlay,
            [gameId],
          ),
        )),
      ) as _i3.Future<_i4.GameModel>);

  @override
  _i3.Future<Map<String, dynamic>> getGameHistory(String? gameId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getGameHistory,
          [gameId],
        ),
        returnValue:
            _i3.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i3.Future<Map<String, dynamic>>);
}

class _FakeGameModel_0 extends _i1.SmartFake implements _i4.GameModel {
  _FakeGameModel_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}
