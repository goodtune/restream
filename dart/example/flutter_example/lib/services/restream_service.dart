import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:restream/restream.dart';

/// SharedPreferences-based token storage for Flutter apps.
class SharedPreferencesTokenStorage implements TokenStorage {
  static const String _tokensKey = 'restream_tokens';

  @override
  Future<void> saveTokens(Map<String, dynamic> tokens) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tokens);
    await prefs.setString(_tokensKey, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tokensKey);

    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // If corrupted, remove it
      await prefs.remove(_tokensKey);
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokensKey);
  }
}

/// Service class that manages Restream.io API interactions.
class RestreamService {
  static const String _clientIdKey = 'restream_client_id';
  static const String _clientSecretKey = 'restream_client_secret';

  RestreamClient? _client;
  OAuthFlow? _oauthFlow;
  PkceParameters? _pendingPkce;
  bool _isConfigured = false;

  RestreamService();

  /// Initialize the service and load stored credentials and tokens.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString(_clientIdKey);
    final clientSecret = prefs.getString(_clientSecretKey);

    if (clientId != null && clientId.isNotEmpty) {
      final config = RestreamConfig(
        clientId: clientId,
        clientSecret: clientSecret?.isEmpty == true ? null : clientSecret,
      );

      _client = RestreamClient(
        config: config,
        tokenStorage: SharedPreferencesTokenStorage(),
      );

      _oauthFlow = OAuthFlow(config: config);
      _isConfigured = true;

      await _client!.initialize();
    }
  }

  /// Check if the service is configured with client credentials.
  bool get isConfigured => _isConfigured;

  /// Check if user is authenticated.
  bool get isAuthenticated => _client?.isAuthenticated ?? false;

  /// Configure the service with client credentials.
  Future<void> configure(
      {required String clientId, String? clientSecret}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, clientId);
    if (clientSecret != null && clientSecret.isNotEmpty) {
      await prefs.setString(_clientSecretKey, clientSecret);
    } else {
      await prefs.remove(_clientSecretKey);
    }

    // Reinitialize with new credentials
    await initialize();
  }

  /// Get stored client credentials.
  Future<Map<String, String?>> getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'clientId': prefs.getString(_clientIdKey),
      'clientSecret': prefs.getString(_clientSecretKey),
    };
  }

  /// Clear stored credentials.
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientIdKey);
    await prefs.remove(_clientSecretKey);
    _client = null;
    _oauthFlow = null;
    _isConfigured = false;
  }

  /// Start OAuth authentication flow.
  Future<String> startAuthFlow() async {
    if (!_isConfigured || _oauthFlow == null || _client == null) {
      throw StateError('Service not configured with client credentials');
    }

    _pendingPkce = _oauthFlow!.generatePkce();

    return _client!.buildAuthorizationUrl(
      redirectUri: 'restreamapp://oauth/callback',
      scopes: ['profile.read', 'stream.read', 'channel.read', 'channel.write'],
      usePkce: true,
    );
  }

  /// Complete OAuth authentication with authorization code.
  Future<void> completeAuthFlow(String authCode) async {
    if (_pendingPkce == null || _client == null) {
      throw StateError('No pending OAuth flow or service not configured');
    }

    await _client!.authenticate(
      authCode: authCode,
      redirectUri: 'restreamapp://oauth/callback',
      codeVerifier: _pendingPkce!.codeVerifier,
    );

    _pendingPkce = null;
  }

  /// Logout and clear stored tokens.
  Future<void> logout() async {
    if (_client != null) {
      await _client!.logout();
    }
  }

  /// Get user profile.
  Future<Profile> getProfile() async {
    if (_client == null) throw StateError('Service not configured');
    return await _client!.getProfile();
  }

  /// Get list of platforms.
  Future<List<Platform>> getPlatforms() async {
    if (_client == null) throw StateError('Service not configured');
    return await _client!.getPlatforms();
  }

  /// Get upcoming events.
  Future<List<StreamEvent>> getUpcomingEvents() async {
    if (_client == null) throw StateError('Service not configured');
    return await _client!.listUpcomingEvents();
  }

  /// Get in-progress events.
  Future<List<StreamEvent>> getInProgressEvents() async {
    if (_client == null) throw StateError('Service not configured');
    return await _client!.listInProgressEvents();
  }

  /// Get primary stream key.
  Future<StreamKey> getStreamKey() async {
    if (_client == null) throw StateError('Service not configured');
    return await _client!.getStreamKey();
  }

  /// Start monitoring chat messages.
  Stream<ChatMessage> startChatMonitoring() async* {
    // Note: This requires a valid access token
    // In a real app, you'd get this from the authenticated client
    final monitor = ChatMonitor(
      accessToken: 'access-token-here', // Get from _client
      maxDuration: const Duration(hours: 1),
    );

    await monitor.start();
    yield* monitor.messages;
  }

  /// Start monitoring streaming events.
  Stream<StreamingEvent> startStreamingMonitoring() async* {
    final monitor = StreamingMonitor(
      accessToken: 'access-token-here', // Get from _client
      maxDuration: const Duration(hours: 1),
    );

    await monitor.start();
    yield* monitor.events;
  }

  /// Dispose of resources.
  void dispose() {
    _client?.dispose();
  }
}
