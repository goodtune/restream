import 'dart:convert';
import 'dart:io';

/// Token storage interface for OAuth tokens.
abstract class TokenStorage {
  /// Save OAuth tokens.
  Future<void> saveTokens(Map<String, dynamic> tokens);

  /// Load OAuth tokens.
  Future<Map<String, dynamic>?> loadTokens();

  /// Clear stored tokens.
  Future<void> clearTokens();
}

/// In-memory token storage (for testing or temporary usage).
class MemoryTokenStorage implements TokenStorage {
  Map<String, dynamic>? _tokens;

  @override
  Future<void> saveTokens(Map<String, dynamic> tokens) async {
    _tokens = Map<String, dynamic>.from(tokens);
  }

  @override
  Future<Map<String, dynamic>?> loadTokens() async {
    return _tokens != null ? Map<String, dynamic>.from(_tokens!) : null;
  }

  @override
  Future<void> clearTokens() async {
    _tokens = null;
  }
}

/// File-based token storage for standalone Dart applications.
class FileTokenStorage implements TokenStorage {
  final String filePath;

  FileTokenStorage(this.filePath);

  /// Default file storage in user's config directory.
  factory FileTokenStorage.defaultPath() {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw StateError('Unable to determine home directory');
    }

    final configDir = '$home/.config/restream_dart';
    return FileTokenStorage('$configDir/tokens.json');
  }

  @override
  Future<void> saveTokens(Map<String, dynamic> tokens) async {
    final file = File(filePath);

    // Create directory if it doesn't exist
    await file.parent.create(recursive: true);

    // Set restrictive permissions (owner read/write only)
    final jsonContent = jsonEncode(tokens);
    await file.writeAsString(jsonContent);

    // Set file permissions to 600 (owner read/write only) on Unix systems
    if (!Platform.isWindows) {
      await Process.run('chmod', ['600', filePath]);
    }
  }

  @override
  Future<Map<String, dynamic>?> loadTokens() async {
    final file = File(filePath);

    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      // If file is corrupted, return null
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Token information extracted from stored tokens.
class TokenInfo {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const TokenInfo({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  /// Creates TokenInfo from stored token data.
  factory TokenInfo.fromTokenData(Map<String, dynamic> data) {
    final accessToken = data['access_token'] as String?;
    if (accessToken == null) {
      throw ArgumentError('access_token is required');
    }

    final refreshToken = data['refresh_token'] as String?;

    DateTime? expiresAt;
    final expiresIn = data['expires_in'] as int?;
    if (expiresIn != null) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    }

    return TokenInfo(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// Check if the access token is expired or close to expiring.
  bool get isExpired {
    if (expiresAt == null) return false;

    // Consider token expired if it expires within the next 5 minutes
    final buffer = Duration(minutes: 5);
    return DateTime.now().add(buffer).isAfter(expiresAt!);
  }

  /// Check if refresh is possible.
  bool get canRefresh => refreshToken != null;

  @override
  String toString() {
    return 'TokenInfo{\n'
        '  accessToken: ${_maskToken(accessToken)},\n'
        '  refreshToken: ${refreshToken != null ? _maskToken(refreshToken!) : 'null'},\n'
        '  expiresAt: $expiresAt,\n'
        '  isExpired: $isExpired\n'
        '}';
  }

  String _maskToken(String token) {
    if (token.length <= 8) return token;
    return '${token.substring(0, 8)}${'*' * (token.length - 8)}';
  }
}
