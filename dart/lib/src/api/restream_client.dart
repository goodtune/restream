import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../auth/oauth_flow.dart';
import '../auth/token_storage.dart';
import '../config/restream_config.dart';
import '../errors/restream_exceptions.dart';
import '../models/channel.dart';
import '../models/platform.dart';
import '../models/profile.dart';
import '../models/server.dart';
import '../models/stream_event.dart';
import '../models/stream_key.dart';

/// Main client for interacting with the Restream.io API.
class RestreamClient {
  final RestreamConfig config;
  final TokenStorage tokenStorage;
  final http.Client _httpClient;
  late final OAuthFlow _oauthFlow;
  
  String? _accessToken;

  RestreamClient({
    RestreamConfig? config,
    TokenStorage? tokenStorage,
    http.Client? httpClient,
  })  : config = config ?? RestreamConfig.fromEnvironment(),
        tokenStorage = tokenStorage ?? MemoryTokenStorage(),
        _httpClient = httpClient ?? http.Client() {
    _oauthFlow = OAuthFlow(config: this.config, httpClient: _httpClient);
  }

  /// Initialize the client by loading stored tokens.
  Future<void> initialize() async {
    final tokens = await tokenStorage.loadTokens();
    if (tokens != null) {
      try {
        final tokenInfo = TokenInfo.fromTokenData(tokens);
        
        // If token is expired but we have a refresh token, try to refresh
        if (tokenInfo.isExpired && tokenInfo.canRefresh) {
          await _refreshAccessToken(tokenInfo.refreshToken!);
        } else {
          _accessToken = tokenInfo.accessToken;
        }
      } catch (e) {
        // If token loading fails, clear invalid tokens
        await tokenStorage.clearTokens();
      }
    }
  }

  /// Check if the client is authenticated.
  bool get isAuthenticated => _accessToken != null;

  /// Generate authorization URL for OAuth flow.
  String buildAuthorizationUrl({
    required String redirectUri,
    List<String> scopes = const ['profile.read', 'stream.read', 'channel.read', 'channel.write'],
    String? state,
    bool usePkce = true,
  }) {
    final pkce = usePkce ? _oauthFlow.generatePkce() : null;
    return _oauthFlow.buildAuthorizationUrl(
      redirectUri: redirectUri,
      scopes: scopes,
      state: state,
      pkce: pkce,
    );
  }

  /// Complete OAuth flow by exchanging authorization code for tokens.
  Future<void> authenticate({
    required String authCode,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    final tokens = await _oauthFlow.exchangeCodeForTokens(
      authCode: authCode,
      redirectUri: redirectUri,
      codeVerifier: codeVerifier,
    );

    await tokenStorage.saveTokens(tokens);
    _accessToken = tokens['access_token'] as String;
  }

  /// Clear authentication and stored tokens.
  Future<void> logout() async {
    _accessToken = null;
    await tokenStorage.clearTokens();
  }

  // Public API endpoints

  /// Get user profile information.
  Future<Profile> getProfile() async {
    final response = await _makeRequest('GET', '/user/profile');
    return Profile.fromJson(response);
  }

  /// Get list of available platforms.
  Future<List<Platform>> getPlatforms() async {
    final response = await _makeRequest('GET', '/platform/all', requireAuth: false);
    final platforms = response as List;
    return platforms.map((p) => Platform.fromJson(p as Map<String, dynamic>)).toList();
  }

  /// Get list of available servers.
  Future<List<Server>> getServers() async {
    final response = await _makeRequest('GET', '/server/all', requireAuth: false);
    final servers = response as List;
    return servers.map((s) => Server.fromJson(s as Map<String, dynamic>)).toList();
  }

  /// Get channel details.
  Future<Channel> getChannel(int channelId) async {
    final response = await _makeRequest('GET', '/user/channel/$channelId');
    return Channel.fromJson(response);
  }

  /// Update channel active status.
  Future<void> updateChannel(int channelId, {required bool active}) async {
    await _makeRequest('PATCH', '/user/channel/$channelId', body: {'active': active});
  }

  /// Get channel metadata.
  Future<ChannelMeta> getChannelMeta(int channelId) async {
    final response = await _makeRequest('GET', '/user/channel-meta/$channelId');
    return ChannelMeta.fromJson(response);
  }

  /// Update channel metadata.
  Future<void> updateChannelMeta(
    int channelId, {
    required String title,
    String? description,
  }) async {
    final body = <String, dynamic>{'title': title};
    if (description != null) {
      body['description'] = description;
    }
    await _makeRequest('PATCH', '/user/channel-meta/$channelId', body: body);
  }

  /// Get specific event details.
  Future<StreamEvent> getEvent(String eventId) async {
    final response = await _makeRequest('GET', '/user/events/$eventId');
    return StreamEvent.fromJson(response);
  }

  /// List upcoming events.
  Future<List<StreamEvent>> listUpcomingEvents({
    int? source,
    bool? scheduled,
  }) async {
    final params = <String, String>{};
    if (source != null) params['source'] = source.toString();
    if (scheduled != null) params['scheduled'] = scheduled.toString();

    final queryString = params.isNotEmpty 
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    final response = await _makeRequest('GET', '/user/events/upcoming$queryString');
    final events = response as List;
    return events.map((e) => StreamEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// List in-progress events.
  Future<List<StreamEvent>> listInProgressEvents() async {
    final response = await _makeRequest('GET', '/user/events/in-progress');
    final events = response as List;
    return events.map((e) => StreamEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// List event history.
  Future<List<StreamEvent>> listEventHistory({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _makeRequest(
      'GET',
      '/user/events/history?page=$page&limit=$limit',
    );
    
    final items = response['items'] as List;
    return items.map((e) => StreamEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get primary stream key.
  Future<StreamKey> getStreamKey() async {
    final response = await _makeRequest('GET', '/user/streamKey');
    return StreamKey.fromJson(response);
  }

  /// Get event-specific stream key.
  Future<StreamKey> getEventStreamKey(String eventId) async {
    final response = await _makeRequest('GET', '/user/events/$eventId/streamKey');
    return StreamKey.fromJson(response);
  }

  // Private helper methods

  Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    if (requireAuth && !isAuthenticated) {
      throw AuthenticationException('Authentication required for this operation');
    }

    final url = Uri.parse('${config.baseUrl}$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    http.Response? response;
    Exception? lastException;

    // Retry logic with exponential backoff
    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        switch (method.toUpperCase()) {
          case 'GET':
            response = await _httpClient.get(url, headers: headers);
            break;
          case 'POST':
            response = await _httpClient.post(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PUT':
            response = await _httpClient.put(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'PATCH':
            response = await _httpClient.patch(
              url,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            );
            break;
          case 'DELETE':
            response = await _httpClient.delete(url, headers: headers);
            break;
          default:
            throw ArgumentError('Unsupported HTTP method: $method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success
          if (response.statusCode == 204 || response.body.isEmpty) {
            return <String, dynamic>{};
          }
          return jsonDecode(response.body);
        } else {
          final apiError = ApiException(
            _parseErrorMessage(response),
            statusCode: response.statusCode,
            responseText: response.body,
            url: url.toString(),
          );

          // Don't retry on non-transient errors
          if (!apiError.isTransient || attempt == config.maxRetries) {
            throw apiError;
          }

          lastException = apiError;
        }
      } catch (e) {
        if (e is ApiException) {
          lastException = e;
          if (!e.isTransient || attempt == config.maxRetries) {
            rethrow;
          }
        } else {
          throw NetworkException('Network error: $e');
        }
      }

      // Wait before retrying (exponential backoff)
      if (attempt < config.maxRetries) {
        final delay = Duration(
          milliseconds: (config.retryBackoffFactor * 1000 * pow(2, attempt)).round(),
        );
        await Future.delayed(delay);
      }
    }

    // If we get here, all retries failed
    throw lastException ?? NetworkException('Request failed after ${config.maxRetries} retries');
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['error'] ?? data['message'] ?? 'Unknown error';
      return message as String;
    } catch (_) {
      return response.body.isNotEmpty ? response.body : 'HTTP ${response.statusCode}';
    }
  }

  Future<void> _refreshAccessToken(String refreshToken) async {
    try {
      final tokens = await _oauthFlow.refreshToken(refreshToken);
      await tokenStorage.saveTokens(tokens);
      _accessToken = tokens['access_token'] as String;
    } catch (e) {
      // If refresh fails, clear tokens
      await tokenStorage.clearTokens();
      _accessToken = null;
      throw AuthenticationException('Token refresh failed: $e');
    }
  }

  /// Dispose of resources.
  void dispose() {
    _oauthFlow.dispose();
    _httpClient.close();
  }
}