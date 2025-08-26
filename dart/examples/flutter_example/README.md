# Flutter Example App for Restream Dart Library

This is a complete Flutter example app demonstrating how to integrate the `restream` library into a Flutter application.

## Features Demonstrated

- ✅ OAuth2 authentication flow with PKCE
- ✅ Secure token storage using SharedPreferences
- ✅ User profile display
- ✅ Event management (upcoming and in-progress streams)
- ✅ Stream key display with copy functionality
- ✅ Real-time chat monitoring setup (structure)
- ✅ Error handling and loading states
- ✅ Material Design 3 UI

## Project Structure

```
lib/
├── main.dart                    # App entry point and navigation
├── services/
│   └── restream_service.dart    # Service layer wrapping restream
├── screens/
│   ├── auth_screen.dart         # OAuth authentication screen
│   └── home_screen.dart         # Main app screen with tabs
└── widgets/                     # Reusable UI components (if needed)
```

## Setup Instructions

### 1. Configure OAuth Application

First, you need to register your application with Restream.io:

1. Go to [Restream.io Developer Console](https://developers.restream.io/)
2. Create a new OAuth application
3. Set the redirect URI to: `restreamapp://oauth/callback`
4. Note your Client ID

### 2. Update Configuration

Edit `lib/services/restream_service.dart` and replace `your-client-id-here` with your actual client ID:

```dart
RestreamClient(
  config: RestreamConfig(
    clientId: 'your-actual-client-id-here',
  ),
  // ...
)
```

### 3. Configure Deep Links

#### Android Configuration

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<activity>` tag:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="restreamapp" android:host="oauth" />
</intent-filter>
```

#### iOS Configuration

Add the following to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>restreamapp.oauth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>restreamapp</string>
        </array>
    </dict>
</array>
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Key Integration Points

### OAuth Flow Implementation

The app demonstrates a complete OAuth2 flow with PKCE:

1. **Start Authentication**: Generate PKCE parameters and authorization URL
2. **Browser Launch**: Open system browser for user authorization
3. **Deep Link Handling**: Capture authorization code from redirect
4. **Token Exchange**: Exchange code for access/refresh tokens
5. **Token Storage**: Securely store tokens using SharedPreferences

### Service Layer Pattern

The `RestreamService` class provides a clean abstraction over the `restream` library:

- Manages client lifecycle
- Handles token storage
- Provides Flutter-friendly async methods
- Encapsulates error handling

### State Management

The example uses simple `setState()` for demonstration, but you can easily integrate with:

- Provider
- Riverpod
- Bloc
- GetX
- Or any other state management solution

### Real-time Features

The chat monitoring setup shows how to integrate WebSocket streams:

```dart
Stream<ChatMessage> startChatMonitoring() async* {
  final monitor = ChatMonitor(accessToken: accessToken);
  await monitor.start();
  yield* monitor.messages;
}
```

## Production Considerations

### Security

1. **Never include client secrets** in mobile apps - use PKCE instead
2. **Validate redirect URIs** to prevent OAuth hijacking
3. **Use certificate pinning** for API requests in production
4. **Encrypt sensitive data** before storing locally

### Error Handling

The example includes basic error handling, but for production:

- Implement retry logic for network failures
- Handle token refresh automatically
- Provide user-friendly error messages
- Log errors for debugging (without sensitive data)

### Performance

- **Cache API responses** where appropriate
- **Implement pagination** for large lists
- **Use FutureBuilder/StreamBuilder** for reactive UI updates
- **Dispose of resources** properly to prevent memory leaks

### Testing

- Mock the `RestreamService` for unit tests
- Use `integration_test` for end-to-end testing
- Test OAuth flow with test credentials
- Mock WebSocket connections for reliable testing

## Common Patterns

### Loading States

```dart
FutureBuilder<Profile>(
  future: _restreamService.getProfile(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return ProfileWidget(profile: snapshot.data!);
  },
)
```

### Stream Monitoring

```dart
StreamBuilder<ChatMessage>(
  stream: _restreamService.startChatMonitoring(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ChatMessageWidget(message: snapshot.data!);
    }
    return const Text('Waiting for messages...');
  },
)
```

### Error Handling

```dart
try {
  final events = await _restreamService.getUpcomingEvents();
  // Update UI with events
} on AuthenticationException {
  // Navigate to login screen
} on ApiException catch (e) {
  // Show API error message
} on NetworkException {
  // Show network error message
}
```

## Next Steps

1. **Implement deep link handling** for automatic OAuth completion
2. **Add real-time chat UI** with message display and filtering
3. **Implement stream management** features (start/stop streaming)
4. **Add push notifications** for stream events
5. **Integrate with streaming software** APIs for advanced features

## Resources

- [Restream.io API Documentation](https://developers.restream.io/)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [OAuth 2.0 with PKCE](https://oauth.net/2/pkce/)
- [restream Library Documentation](../../README.md)