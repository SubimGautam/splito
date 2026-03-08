import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:splito_project/features/auth/data/datasource/local/local_auth_datasource.dart'
    as _i4;
import 'package:splito_project/features/auth/data/datasource/remote/remote_auth_datasource.dart'
    as _i2;

class MockRemoteAuthDataSourceImpl extends _i1.Mock
    implements _i2.RemoteAuthDataSourceImpl {
  MockRemoteAuthDataSourceImpl() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int min(
    int? a,
    int? b,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #min,
          [
            a,
            b,
          ],
        ),
        returnValue: 0,
      ) as int);

  @override
  _i3.Future<Map<String, dynamic>> signUp(
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUp,
          [
            username,
            email,
            password,
            confirmPassword,
          ],
        ),
        returnValue:
            _i3.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> signIn(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [
            email,
            password,
          ],
        ),
        returnValue:
            _i3.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> getProfile() => (super.noSuchMethod(
        Invocation.method(
          #getProfile,
          [],
        ),
        returnValue:
            _i3.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<void> logout() => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

class MockLocalAuthDataSourceImpl extends _i1.Mock
    implements _i4.LocalAuthDataSourceImpl {
  MockLocalAuthDataSourceImpl() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> saveCredentials(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveCredentials,
          [
            email,
            password,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<Map<String, String>?> getCredentials() => (super.noSuchMethod(
        Invocation.method(
          #getCredentials,
          [],
        ),
        returnValue: _i3.Future<Map<String, String>?>.value(),
      ) as _i3.Future<Map<String, String>?>);

  @override
  _i3.Future<void> clearAllAuthData() => (super.noSuchMethod(
        Invocation.method(
          #clearAllAuthData,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
