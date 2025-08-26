/// Configuration management for the Restream.io client.
/// 
/// This module handles configuration settings including API base URLs,
/// client credentials, and other settings.
library;

/// Configuration class for Restream.io client settings.
class RestreamConfig {
  /// Default API base URL.
  static const String defaultBaseUrl = 'https://api.restream.io/v2';
  
  /// OAuth token endpoint.
  static const String tokenEndpoint = 'https://api.restream.io/oauth/token';
  
  /// OAuth authorization endpoint.
  static const String authEndpoint = 'https://api.restream.io/oauth/authorize';
  
  /// WebSocket streaming endpoint base.
  static const String streamingWebSocketUrl = 'wss://streaming.api.restream.io/ws';
  
  /// WebSocket chat endpoint base.
  static const String chatWebSocketUrl = 'wss://chat.api.restream.io/ws';
  
  /// API base URL (can be overridden for testing).
  final String baseUrl;
  
  /// OAuth client ID.
  final String? clientId;
  
  /// OAuth client secret (optional for PKCE flow).
  final String? clientSecret;
  
  /// Request timeout duration.
  final Duration timeout;
  
  /// Number of retry attempts for failed requests.
  final int maxRetries;
  
  /// Backoff factor for retry attempts.
  final double retryBackoffFactor;

  const RestreamConfig({
    this.baseUrl = defaultBaseUrl,
    this.clientId,
    this.clientSecret,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryBackoffFactor = 0.5,
  });

  /// Creates a config with environment variables or defaults.
  factory RestreamConfig.fromEnvironment() {
    return RestreamConfig(
      clientId: const String.fromEnvironment('RESTREAM_CLIENT_ID'),
      clientSecret: const String.fromEnvironment('RESTREAM_CLIENT_SECRET'),
    );
  }

  /// Returns whether the client ID is configured.
  bool get hasClientId => clientId != null && clientId!.isNotEmpty;

  /// Returns whether the client secret is configured.
  bool get hasClientSecret => clientSecret != null && clientSecret!.isNotEmpty;

  /// Creates a copy with updated values.
  RestreamConfig copyWith({
    String? baseUrl,
    String? clientId,
    String? clientSecret,
    Duration? timeout,
    int? maxRetries,
    double? retryBackoffFactor,
  }) {
    return RestreamConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryBackoffFactor: retryBackoffFactor ?? this.retryBackoffFactor,
    );
  }

  @override
  String toString() {
    return 'RestreamConfig{\n'
           '  baseUrl: $baseUrl,\n'
           '  clientId: ${hasClientId ? '***' : 'null'},\n'
           '  clientSecret: ${hasClientSecret ? '***' : 'null'},\n'
           '  timeout: $timeout,\n'
           '  maxRetries: $maxRetries,\n'
           '  retryBackoffFactor: $retryBackoffFactor\n'
           '}';
  }
}