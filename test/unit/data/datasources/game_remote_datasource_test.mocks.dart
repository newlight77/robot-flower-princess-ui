// Mocks generated for GameRemoteDataSource tests
// ignore_for_file: no_leading_underscores_for_library_prefixes, type=lint
// ignore_for_file: avoid_redundant_argument_values, avoid_setters_without_getters
// ignore_for_file: comment_references, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports, invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable, prefer_const_constructors, unnecessary_parenthesis
// ignore_for_file: camel_case_types, subtype_of_sealed_class

import 'dart:async' as _i3;

import 'package:dio/dio.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:robot_flower_princess_front/core/network/api_client.dart'
    as _i4;

class _FakeResponse_0<T> extends _i1.SmartFake implements _i2.Response<T> {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ApiClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockApiClient extends _i1.Mock implements _i4.ApiClient {
  MockApiClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i2.Response<dynamic>> get(
    String? path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [path],
          {#queryParameters: queryParameters},
        ),
        returnValue:
            _i3.Future<_i2.Response<dynamic>>.value(_FakeResponse_0<dynamic>(
          this,
          Invocation.method(
            #get,
            [path],
            {#queryParameters: queryParameters},
          ),
        )),
      ) as _i3.Future<_i2.Response<dynamic>>);

  @override
  _i3.Future<_i2.Response<dynamic>> post(
    String? path, {
    dynamic data,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [path],
          {#data: data},
        ),
        returnValue:
            _i3.Future<_i2.Response<dynamic>>.value(_FakeResponse_0<dynamic>(
          this,
          Invocation.method(
            #post,
            [path],
            {#data: data},
          ),
        )),
      ) as _i3.Future<_i2.Response<dynamic>>);

  @override
  _i3.Future<_i2.Response<dynamic>> put(
    String? path, {
    dynamic data,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [path],
          {#data: data},
        ),
        returnValue:
            _i3.Future<_i2.Response<dynamic>>.value(_FakeResponse_0<dynamic>(
          this,
          Invocation.method(
            #put,
            [path],
            {#data: data},
          ),
        )),
      ) as _i3.Future<_i2.Response<dynamic>>);

  @override
  _i3.Future<_i2.Response<dynamic>> delete(String? path) => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [path],
        ),
        returnValue:
            _i3.Future<_i2.Response<dynamic>>.value(_FakeResponse_0<dynamic>(
          this,
          Invocation.method(
            #delete,
            [path],
          ),
        )),
      ) as _i3.Future<_i2.Response<dynamic>>);
}
