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
  late final RestreamClient _client;
  late final OAuthFlow _oauthFlow;
  PkceParameters? _pendingPkce;

  RestreamService() {
    // Configure with your OAuth app credentials
    final config = RestreamConfig(
      clientId: 'your-client-id-here',
      // Don't include client secret in mobile apps
    );

    _client = RestreamClient(
      config: config,
      tokenStorage: SharedPreferencesTokenStorage(),
    );

    _oauthFlow = OAuthFlow(config: config);
  }

  /// Initialize the service and load stored tokens.
  Future<void> initialize() async {
    await _client.initialize();
  }

  /// Check if user is authenticated.
  bool get isAuthenticated => _client.isAuthenticated;

  /// Start OAuth authentication flow.
  Future<String> startAuthFlow() async {
    _pendingPkce = _oauthFlow.generatePkce();

    return _client.buildAuthorizationUrl(
      redirectUri: 'restreamapp://oauth/callback',
      scopes: ['profile.read', 'stream.read', 'channel.read', 'channel.write'],
      usePkce: true,
    );
  }

  /// Complete OAuth authentication with authorization code.
  Future<void> completeAuthFlow(String authCode) async {
    if (_pendingPkce == null) {
      throw StateError('No pending OAuth flow');
    }

    await _client.authenticate(
      authCode: authCode,
      redirectUri: 'restreamapp://oauth/callback',
      codeVerifier: _pendingPkce!.codeVerifier,
    );

    _pendingPkce = null;
  }

  /// Logout and clear stored tokens.
  Future<void> logout() async {
    await _client.logout();
  }

  /// Get user profile.
  Future<Profile> getProfile() async {
    return await _client.getProfile();
  }

  /// Get list of platforms.
  Future<List<Platform>> getPlatforms() async {
    return await _client.getPlatforms();
  }

  /// Get upcoming events.
  Future<List<StreamEvent>> getUpcomingEvents() async {
    return await _client.listUpcomingEvents();
  }

  /// Get in-progress events.
  Future<List<StreamEvent>> getInProgressEvents() async {
    return await _client.listInProgressEvents();
  }

  /// Get primary stream key.
  Future<StreamKey> getStreamKey() async {
    return await _client.getStreamKey();
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
    _client.dispose();
  }
}
