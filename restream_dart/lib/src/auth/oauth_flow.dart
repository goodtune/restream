import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../config/restream_config.dart';
import '../errors/restream_exceptions.dart';

/// OAuth2 flow implementation for Restream.io authentication.
class OAuthFlow {
  final RestreamConfig config;
  final http.Client _httpClient;

  OAuthFlow({
    required this.config,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Generate PKCE (Proof Key for Code Exchange) parameters.
  PkceParameters generatePkce() {
    // Generate code verifier (43-128 characters, URL-safe base64)
    final random = Random.secure();
    final codeVerifierBytes = Uint8List(32);
    for (int i = 0; i < codeVerifierBytes.length; i++) {
      codeVerifierBytes[i] = random.nextInt(256);
    }
    
    final codeVerifier = base64Url.encode(codeVerifierBytes).replaceAll('=', '');
    
    // Generate code challenge (SHA256 hash of verifier, base64url encoded)
    final challengeBytes = sha256.convert(utf8.encode(codeVerifier)).bytes;
    final codeChallenge = base64Url.encode(challengeBytes).replaceAll('=', '');
    
    return PkceParameters(
      codeVerifier: codeVerifier,
      codeChallenge: codeChallenge,
    );
  }

  /// Generate authorization URL for OAuth flow.
  /// 
  /// [redirectUri] - The redirect URI configured in your OAuth app
  /// [scopes] - List of scopes to request (e.g., ['profile.read', 'stream.read'])
  /// [state] - Optional state parameter for CSRF protection
  /// [pkce] - Optional PKCE parameters for enhanced security
  String buildAuthorizationUrl({
    required String redirectUri,
    required List<String> scopes,
    String? state,
    PkceParameters? pkce,
  }) {
    if (!config.hasClientId) {
      throw ArgumentError('Client ID is required for OAuth flow');
    }

    final params = <String, String>{
      'response_type': 'code',
      'client_id': config.clientId!,
      'redirect_uri': redirectUri,
      'scope': scopes.join(' '),
    };

    if (state != null) {
      params['state'] = state;
    }

    if (pkce != null) {
      params['code_challenge'] = pkce.codeChallenge;
      params['code_challenge_method'] = 'S256';
    }

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${RestreamConfig.authEndpoint}?$queryString';
  }

  /// Exchange authorization code for access tokens.
  /// 
  /// [authCode] - Authorization code received from the callback
  /// [redirectUri] - The same redirect URI used in authorization
  /// [codeVerifier] - PKCE code verifier if PKCE was used
  Future<Map<String, dynamic>> exchangeCodeForTokens({
    required String authCode,
    required String redirectUri,
    String? codeVerifier,
  }) async {
    if (!config.hasClientId) {
      throw AuthenticationException('Client ID is required for token exchange');
    }

    final body = <String, String>{
      'grant_type': 'authorization_code',
      'client_id': config.clientId!,
      'code': authCode,
      'redirect_uri': redirectUri,
    };

    // Use PKCE if code verifier provided
    if (codeVerifier != null) {
      body['code_verifier'] = codeVerifier;
    } else if (config.hasClientSecret) {
      // Use client secret if PKCE not used
      body['client_secret'] = config.clientSecret!;
    } else {
      throw AuthenticationException(
        'Either client secret or PKCE code verifier is required',
      );
    }

    try {
      final response = await _httpClient.post(
        Uri.parse(RestreamConfig.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&'),
      ).timeout(config.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = _parseErrorResponse(response);
        throw AuthenticationException(
          'Token exchange failed: ${response.statusCode} - $errorData',
        );
      }
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Network error during token exchange: $e');
    }
  }

  /// Refresh access token using refresh token.
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    if (!config.hasClientId) {
      throw AuthenticationException('Client ID is required for token refresh');
    }

    final body = <String, String>{
      'grant_type': 'refresh_token',
      'client_id': config.clientId!,
      'refresh_token': refreshToken,
    };

    if (config.hasClientSecret) {
      body['client_secret'] = config.clientSecret!;
    }

    try {
      final response = await _httpClient.post(
        Uri.parse(RestreamConfig.tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&'),
      ).timeout(config.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorData = _parseErrorResponse(response);
        throw AuthenticationException(
          'Token refresh failed: ${response.statusCode} - $errorData',
        );
      }
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Network error during token refresh: $e');
    }
  }

  String _parseErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'] as String?;
      final description = data['error_description'] as String?;
      
      if (description != null) {
        return description;
      } else if (error != null) {
        return error;
      }
    } catch (_) {
      // Fall back to response body
    }
    
    return response.body.isNotEmpty ? response.body : 'Unknown error';
  }

  void dispose() {
    _httpClient.close();
  }
}

/// PKCE (Proof Key for Code Exchange) parameters.
class PkceParameters {
  final String codeVerifier;
  final String codeChallenge;

  const PkceParameters({
    required this.codeVerifier,
    required this.codeChallenge,
  });

  @override
  String toString() {
    return 'PkceParameters{\n'
           '  codeVerifier: ${_mask(codeVerifier)},\n'
           '  codeChallenge: $codeChallenge\n'
           '}';
  }

  String _mask(String value) {
    if (value.length <= 8) return value;
    return '${value.substring(0, 8)}${'*' * (value.length - 8)}';
  }
}