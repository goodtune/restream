/// A Dart library for interacting with the Restream.io REST API and WebSocket APIs.
///
/// This library provides a complete interface to the Restream.io platform,
/// including OAuth2 authentication, REST API endpoints, and real-time WebSocket
/// monitoring capabilities. It's designed to be easily integrated into Flutter
/// applications.
///
/// Features:
/// - OAuth2 authentication flow optimized for mobile apps
/// - Complete REST API coverage (profiles, channels, events, stream keys)
/// - WebSocket support for real-time streaming and chat monitoring
/// - Proper error handling and type safety
/// - Flutter-friendly async/await patterns
///
/// Example usage:
/// ```dart
/// import 'package:restream_dart/restream_dart.dart';
///
/// // Initialize client
/// final client = RestreamClient();
///
/// // Authenticate (handle OAuth flow)
/// await client.authenticate();
///
/// // Use API endpoints
/// final profile = await client.getProfile();
/// final events = await client.listEvents();
/// ```
library;

// Core API client
export 'src/api/restream_client.dart';

// Authentication
export 'src/auth/oauth_flow.dart';
export 'src/auth/token_storage.dart';

// Models
export 'src/models/profile.dart';
export 'src/models/stream_event.dart';
export 'src/models/event_destination.dart';
export 'src/models/channel.dart';
export 'src/models/platform.dart';
export 'src/models/platform_image.dart';
export 'src/models/server.dart';
export 'src/models/stream_key.dart';

// WebSocket
export 'src/websocket/streaming_monitor.dart';
export 'src/websocket/chat_monitor.dart';

// Configuration
export 'src/config/restream_config.dart';

// Errors
export 'src/errors/restream_exceptions.dart';
