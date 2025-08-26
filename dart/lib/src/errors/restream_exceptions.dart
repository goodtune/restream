/// Exception classes for Restream.io API errors.
///
/// This module defines custom exceptions that map to the error conditions
/// that can occur when interacting with the Restream.io API.
library;

/// Base exception for all Restream.io API errors.
class RestreamException implements Exception {
  /// The error message.
  final String message;

  /// Optional status code from HTTP response.
  final int? statusCode;

  /// Optional response text from the server.
  final String? responseText;

  /// Optional URL that caused the error.
  final String? url;

  const RestreamException(
    this.message, {
    this.statusCode,
    this.responseText,
    this.url,
  });

  /// Check if this error might be transient and worth retrying.
  bool get isTransient {
    if (statusCode == null) return false;

    // 5xx server errors and some 4xx client errors are considered transient
    return statusCode! >= 500 || // Server errors
        statusCode == 429 || // Rate limiting
        statusCode == 408; // Request timeout
  }

  @override
  String toString() {
    final parts = <String>[message];

    if (statusCode != null) {
      parts.add('Status: $statusCode');
    }

    if (url != null) {
      parts.add('URL: $url');
    }

    if (responseText != null) {
      // Truncate long responses
      final response = responseText!.length > 200
          ? '${responseText!.substring(0, 200)}...'
          : responseText!;
      parts.add('Response: $response');
    }

    return parts.join(' | ');
  }
}

/// Exception raised when API requests fail.
class ApiException extends RestreamException {
  const ApiException(
    super.message, {
    super.statusCode,
    super.responseText,
    super.url,
  });
}

/// Exception raised when OAuth authentication fails.
class AuthenticationException extends RestreamException {
  const AuthenticationException(super.message);
}

/// Exception raised when network operations fail.
class NetworkException extends RestreamException {
  const NetworkException(super.message);
}

/// Exception raised when WebSocket operations fail.
class WebSocketException extends RestreamException {
  const WebSocketException(super.message);
}
