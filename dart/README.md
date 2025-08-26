# Restream Dart

A comprehensive Dart library for interacting with the [Restream.io](https://restream.io) REST API and WebSocket APIs. This library is designed specifically for Flutter applications but can be used in any Dart project.

## Features

- 🔐 **OAuth2 Authentication** - Complete OAuth2 flow with PKCE support for secure mobile authentication
- 🌐 **REST API Coverage** - Full access to user profiles, channels, events, stream keys, platforms, and servers
- 📡 **WebSocket Support** - Real-time streaming and chat monitoring capabilities
- 🔧 **Type Safety** - Comprehensive data models with JSON serialization
- ⚡ **Async/Await** - Flutter-friendly asynchronous patterns
- 🔄 **Retry Logic** - Built-in retry mechanism with exponential backoff
- 💾 **Token Storage** - Secure token storage with configurable backends

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  restream: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Quick Start

### 1. Basic Setup

```dart
import 'package:restream/restream.dart';

// Configure the client
final client = RestreamClient(
  config: RestreamConfig(
    clientId: 'your-client-id',
    // clientSecret: 'your-client-secret', // Optional with PKCE
  ),
  tokenStorage: FileTokenStorage.defaultPath(), // or MemoryTokenStorage()
);

// Initialize to load existing tokens
await client.initialize();
```

### 2. Authentication

```dart
// Generate authorization URL
final authUrl = client.buildAuthorizationUrl(
  redirectUri: 'your-app://oauth/callback',
  scopes: ['profile.read', 'stream.read', 'channel.read'],
  usePkce: true, // Recommended for mobile apps
);

// Open browser/WebView for user to authorize
await launchUrl(Uri.parse(authUrl));

// After receiving the authorization code from redirect:
await client.authenticate(
  authCode: 'received-authorization-code',
  redirectUri: 'your-app://oauth/callback',
  codeVerifier: 'pkce-code-verifier-if-used',
);
```

### 3. API Usage

```dart
// Get user profile
final profile = await client.getProfile();
print('User: ${profile.username}');

// List upcoming events
final events = await client.listUpcomingEvents();
for (final event in events) {
  print('Event: ${event.title} (${event.status})');
}

// Get stream key
final streamKey = await client.getStreamKey();
print('RTMP URL: ${streamKey.rtmpUrl}');

// Update channel metadata
await client.updateChannelMeta(
  channelId,
  title: 'My New Stream Title',
  description: 'Updated description',
);
```

### 4. WebSocket Monitoring

```dart
// Monitor streaming events
final streamingMonitor = StreamingMonitor(
  accessToken: await client.getAccessToken(),
  maxDuration: Duration(minutes: 30), // Optional
);

streamingMonitor.events.listen((event) {
  print('Streaming event: ${event.action}');
  print('Payload: ${event.payload}');
});

await streamingMonitor.start();

// Monitor chat messages
final chatMonitor = ChatMonitor(
  accessToken: await client.getAccessToken(),
);

chatMonitor.messages.listen((message) {
  print('${message.platform} - ${message.username}: ${message.message}');
});

await chatMonitor.start();
```

## API Reference

### RestreamClient

The main client class for API interactions.

#### Methods

- `initialize()` - Load stored tokens
- `buildAuthorizationUrl()` - Generate OAuth authorization URL
- `authenticate()` - Exchange authorization code for tokens
- `logout()` - Clear authentication and tokens
- `getProfile()` - Get user profile
- `getPlatforms()` - Get available streaming platforms
- `getServers()` - Get available ingest servers
- `getChannel(id)` - Get channel details
- `updateChannel(id, active)` - Enable/disable channel
- `getChannelMeta(id)` - Get channel metadata
- `updateChannelMeta(id, title, description)` - Update channel metadata
- `getEvent(id)` - Get event details
- `listUpcomingEvents()` - List upcoming events
- `listInProgressEvents()` - List active events
- `listEventHistory()` - List past events
- `getStreamKey()` - Get primary stream key
- `getEventStreamKey(id)` - Get event-specific stream key

### Models

All API responses are mapped to strongly-typed Dart models:

- `Profile` - User profile information
- `StreamEvent` - Stream event details
- `Channel` / `ChannelMeta` - Channel information and metadata
- `Platform` / `PlatformImage` - Streaming platform details
- `Server` - Ingest server information
- `StreamKey` - RTMP streaming credentials
- `EventDestination` - Stream destination details

### WebSocket Monitors

- `StreamingMonitor` - Real-time streaming status and metrics
- `ChatMonitor` - Real-time chat events and messages

### Configuration

```dart
final config = RestreamConfig(
  baseUrl: 'https://api.restream.io/v2', // API base URL
  clientId: 'your-client-id',
  clientSecret: 'your-client-secret', // Optional
  timeout: Duration(seconds: 30),
  maxRetries: 3,
  retryBackoffFactor: 0.5,
);
```

### Token Storage

Choose from different token storage backends:

```dart
// In-memory (not persistent)
final storage = MemoryTokenStorage();

// File-based (persistent)
final storage = FileTokenStorage.defaultPath();
final storage = FileTokenStorage('/custom/path/tokens.json');
```

## Flutter Integration

### Deep Link Handling

```dart
// Configure deep links in your app for OAuth redirect
// Add to android/app/src/main/AndroidManifest.xml:
<activity>
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="yourapp" android:host="oauth" />
  </intent-filter>
</activity>
```

### Complete Flutter Example

```dart
class RestreamService {
  late final RestreamClient _client;
  
  RestreamService() {
    _client = RestreamClient(
      config: RestreamConfig(clientId: 'your-client-id'),
      tokenStorage: SharedPreferencesTokenStorage(), // Custom implementation
    );
  }
  
  Future<void> authenticate(BuildContext context) async {
    final authUrl = _client.buildAuthorizationUrl(
      redirectUri: 'yourapp://oauth/callback',
      scopes: ['profile.read', 'stream.read'],
    );
    
    await launchUrl(Uri.parse(authUrl));
    // Handle deep link callback to complete authentication
  }
  
  Stream<ChatMessage> chatStream() {
    final monitor = ChatMonitor(accessToken: _getAccessToken());
    monitor.start();
    return monitor.messages;
  }
}
```

## Error Handling

The library provides comprehensive error handling:

```dart
try {
  final profile = await client.getProfile();
} on AuthenticationException {
  // Handle authentication errors
  print('Please log in again');
} on ApiException catch (e) {
  // Handle API errors
  print('API Error: ${e.message} (${e.statusCode})');
} on NetworkException {
  // Handle network errors
  print('Network error - please check connection');
}
```

## Development

### Running Tests

```bash
dart test
```

### Building

```bash
dart run build_runner build
```

### Generating Documentation

```bash
dart doc
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run tests and ensure they pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Related Projects

- [restream](https://github.com/goodtune/restream) - Multi-language SDK repository
- [Restream.io API Documentation](https://developers.restream.io/) - Official API documentation

## Support

- [Issues](https://github.com/goodtune/restream/issues) - Report bugs or request features
- [API Documentation](https://developers.restream.io/) - Official Restream.io API docs
