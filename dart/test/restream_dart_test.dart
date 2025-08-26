import 'package:test/test.dart';

import 'package:restream_dart/restream_dart.dart';

void main() {
  group('Restream Dart Library Tests', () {
    test('RestreamConfig can be created with defaults', () {
      final config = RestreamConfig();
      
      expect(config.baseUrl, equals('https://api.restream.io/v2'));
      expect(config.timeout, equals(Duration(seconds: 30)));
      expect(config.maxRetries, equals(3));
      expect(config.retryBackoffFactor, equals(0.5));
    });

    test('RestreamConfig can be created with custom values', () {
      final config = RestreamConfig(
        baseUrl: 'https://test.api.example.com',
        clientId: 'test-client-id',
        clientSecret: 'test-client-secret',
        timeout: Duration(seconds: 10),
        maxRetries: 5,
        retryBackoffFactor: 1.0,
      );
      
      expect(config.baseUrl, equals('https://test.api.example.com'));
      expect(config.hasClientId, isTrue);
      expect(config.hasClientSecret, isTrue);
      expect(config.timeout, equals(Duration(seconds: 10)));
      expect(config.maxRetries, equals(5));
      expect(config.retryBackoffFactor, equals(1.0));
    });

    test('Profile model can be created and serialized', () {
      final profile = Profile(
        id: 123,
        username: 'testuser',
        email: 'test@example.com',
      );
      
      expect(profile.id, equals(123));
      expect(profile.username, equals('testuser'));
      expect(profile.email, equals('test@example.com'));
      
      final json = profile.toJson();
      expect(json['id'], equals(123));
      expect(json['username'], equals('testuser'));
      expect(json['email'], equals('test@example.com'));
      
      final fromJson = Profile.fromJson(json);
      expect(fromJson, equals(profile));
    });

    test('StreamEvent model can be created and serialized', () {
      final event = StreamEvent(
        id: 'test-event-id',
        status: 'live',
        title: 'Test Stream',
        description: 'A test streaming event',
        isInstant: false,
        isRecordOnly: false,
        destinations: [],
      );
      
      expect(event.id, equals('test-event-id'));
      expect(event.status, equals('live'));
      expect(event.title, equals('Test Stream'));
      
      final json = event.toJson();
      expect(json['id'], equals('test-event-id'));
      expect(json['status'], equals('live'));
      expect(json['title'], equals('Test Stream'));
      
      final fromJson = StreamEvent.fromJson(json);
      expect(fromJson.id, equals(event.id));
      expect(fromJson.status, equals(event.status));
      expect(fromJson.title, equals(event.title));
    });

    test('RestreamException provides proper error details', () {
      final exception = ApiException(
        'Test error',
        statusCode: 404,
        responseText: 'Not found',
        url: 'https://api.example.com/test',
      );
      
      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(404));
      expect(exception.responseText, equals('Not found'));
      expect(exception.url, equals('https://api.example.com/test'));
      expect(exception.isTransient, isFalse);
      
      final transientException = ApiException(
        'Server error',
        statusCode: 500,
      );
      expect(transientException.isTransient, isTrue);
    });

    test('TokenInfo can be created from token data', () {
      final tokenData = {
        'access_token': 'test-access-token',
        'refresh_token': 'test-refresh-token',
        'expires_in': 3600,
      };
      
      final tokenInfo = TokenInfo.fromTokenData(tokenData);
      
      expect(tokenInfo.accessToken, equals('test-access-token'));
      expect(tokenInfo.refreshToken, equals('test-refresh-token'));
      expect(tokenInfo.canRefresh, isTrue);
      expect(tokenInfo.isExpired, isFalse);
    });

    test('OAuthFlow can generate PKCE parameters', () {
      final config = RestreamConfig(clientId: 'test-client-id');
      final oauthFlow = OAuthFlow(config: config);
      
      final pkce = oauthFlow.generatePkce();
      
      expect(pkce.codeVerifier.length, greaterThanOrEqualTo(43));
      expect(pkce.codeChallenge.length, greaterThanOrEqualTo(40));
      expect(pkce.codeVerifier, isNot(equals(pkce.codeChallenge)));
    });

    test('OAuthFlow can build authorization URL', () {
      final config = RestreamConfig(clientId: 'test-client-id');
      final oauthFlow = OAuthFlow(config: config);
      
      final url = oauthFlow.buildAuthorizationUrl(
        redirectUri: 'http://localhost:8080/callback',
        scopes: ['profile.read', 'stream.read'],
        state: 'test-state',
      );
      
      expect(url, contains('https://api.restream.io/oauth/authorize'));
      expect(url, contains('client_id=test-client-id'));
      expect(url, contains('redirect_uri=http%3A%2F%2Flocalhost%3A8080%2Fcallback'));
      expect(url, contains('scope=profile.read%20stream.read'));
      expect(url, contains('state=test-state'));
    });
  });
}
