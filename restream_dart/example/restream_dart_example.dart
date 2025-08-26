import 'package:restream_dart/restream_dart.dart';

/// Example demonstrating how to use the Restream Dart library.
/// 
/// This example shows the basic usage patterns for authentication,
/// API calls, and WebSocket monitoring.
Future<void> main() async {
  print('Restream Dart Library Example');
  print('============================\n');

  // 1. Configuration
  print('1. Setting up configuration...');
  final config = RestreamConfig(
    clientId: 'your-client-id-here',
    // For production apps, store client secret securely
    clientSecret: 'your-client-secret-here', // Optional for PKCE flow
  );
  
  // 2. Create client with memory token storage for this example
  print('2. Creating Restream client...');
  final client = RestreamClient(
    config: config,
    tokenStorage: MemoryTokenStorage(), // Use FileTokenStorage for persistence
  );

  try {
    // 3. OAuth Authentication Flow
    print('3. OAuth Authentication (simulated)...');
    
    // In a real app, you would:
    // a) Generate authorization URL
    final authUrl = client.buildAuthorizationUrl(
      redirectUri: 'http://localhost:8080/callback',
      scopes: ['profile.read', 'stream.read', 'channel.read'],
      usePkce: true,
    );
    print('   Authorization URL: $authUrl');
    
    // b) User would visit this URL and authorize your app
    // c) You'd receive the authorization code in your redirect URI
    // d) Exchange the code for tokens:
    // await client.authenticate(
    //   authCode: 'received-auth-code',
    //   redirectUri: 'http://localhost:8080/callback',
    //   codeVerifier: 'pkce-code-verifier',
    // );
    
    print('   (In a real app, complete OAuth flow here)\n');

    // 4. Example API calls (these would work after authentication)
    print('4. Example API Usage:');
    print('   Note: These calls require valid authentication\n');

    // Public endpoints (no authentication required)
    print('   Getting platforms...');
    try {
      final platforms = await client.getPlatforms();
      print('   Found ${platforms.length} platforms:');
      for (final platform in platforms.take(3)) {
        print('     - ${platform.name} (ID: ${platform.id})');
      }
    } catch (e) {
      print('   Error: $e');
    }

    print('\n   Getting servers...');
    try {
      final servers = await client.getServers();
      print('   Found ${servers.length} servers:');
      for (final server in servers.take(3)) {
        print('     - ${server.name} (${server.latitude}, ${server.longitude})');
      }
    } catch (e) {
      print('   Error: $e');
    }

    // Authenticated endpoints (require valid tokens)
    print('\n   Authenticated endpoints (require valid tokens):');
    print('     - client.getProfile() - Get user profile');
    print('     - client.listUpcomingEvents() - List upcoming streams');
    print('     - client.getStreamKey() - Get primary stream key');
    print('     - client.getChannel(channelId) - Get channel details');
    print('     - client.updateChannelMeta(id, title: "New Title") - Update metadata');

    // 5. WebSocket Monitoring Example
    print('\n5. WebSocket Monitoring (simulated):');
    print('   Note: These require valid access tokens\n');

    // Streaming monitor example
    print('   Streaming Monitor:');
    final streamingMonitor = StreamingMonitor(
      accessToken: 'your-access-token-here',
      maxDuration: Duration(seconds: 30), // Monitor for 30 seconds
    );

    streamingMonitor.events.listen((event) {
      print('   📺 Streaming Event: ${event.action} - ${event.payload}');
    });

    streamingMonitor.errors.listen((error) {
      print('   ❌ Streaming Error: $error');
    });

    // Chat monitor example  
    print('   Chat Monitor:');
    final chatMonitor = ChatMonitor(
      accessToken: 'your-access-token-here',
      maxDuration: Duration(seconds: 30),
    );

    chatMonitor.messages.listen((message) {
      print('   💬 Chat: ${message.toString()}');
    });

    chatMonitor.errors.listen((error) {
      print('   ❌ Chat Error: $error');
    });

    // In a real app with valid tokens, you would start monitoring:
    // await streamingMonitor.start();
    // await chatMonitor.start();
    
    print('   (Monitoring would start here with valid tokens)');

    // 6. Model Examples
    print('\n6. Working with Models:');
    
    final sampleEvent = StreamEvent(
      id: 'sample-event-123',
      status: 'live',
      title: 'My Gaming Stream',
      description: 'Playing the latest indie games',
      isInstant: false,
      isRecordOnly: false,
      scheduledFor: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      destinations: [],
    );
    
    print('   Sample Stream Event:');
    print('   ${sampleEvent.toString().replaceAll('\n', '\n   ')}');

    final sampleProfile = Profile(
      id: 12345,
      username: 'streamer_pro',
      email: 'streamer@example.com',
    );
    
    print('\n   Sample Profile:');
    print('   ${sampleProfile.toString().replaceAll('\n', '\n   ')}');

    // JSON serialization example
    print('\n   JSON Serialization:');
    final eventJson = sampleEvent.toJson();
    print('   Event as JSON: ${eventJson.keys.join(', ')}');
    
    final eventFromJson = StreamEvent.fromJson(eventJson);
    print('   Deserialized ID: ${eventFromJson.id}');

  } finally {
    // 7. Cleanup
    print('\n7. Cleaning up...');
    client.dispose();
    print('   Client disposed.');
  }

  print('\n✅ Example completed!');
  print('\nNext steps:');
  print('1. Set up your OAuth application with Restream.io');
  print('2. Configure your client ID and redirect URI');
  print('3. Implement the OAuth flow in your Flutter app');
  print('4. Use the API endpoints to interact with Restream.io');
  print('5. Set up WebSocket monitoring for real-time features');
}

/// Example of setting up OAuth in a Flutter app context
void flutterExample() {
  print('\nFlutter Integration Example:');
  print('============================');
  
  print('''
// In your Flutter app:

class RestreamService {
  late final RestreamClient _client;
  
  RestreamService() {
    _client = RestreamClient(
      config: RestreamConfig(
        clientId: 'your-client-id',
        // Don't include client secret in mobile apps - use PKCE
      ),
      tokenStorage: SharedPreferencesTokenStorage(), // Custom implementation
    );
  }
  
  Future<void> authenticate() async {
    // 1. Generate authorization URL with PKCE
    final pkce = PkceParameters.generate();
    final authUrl = _client.buildAuthorizationUrl(
      redirectUri: 'your-app://oauth/callback',
      scopes: ['profile.read', 'stream.read'],
      usePkce: true,
    );
    
    // 2. Open browser or in-app WebView
    await launchUrl(Uri.parse(authUrl));
    
    // 3. Handle callback and extract auth code
    // (implement deep link handling)
    
    // 4. Exchange code for tokens
    await _client.authenticate(
      authCode: receivedAuthCode,
      redirectUri: 'your-app://oauth/callback',
      codeVerifier: pkce.codeVerifier,
    );
  }
  
  Future<Profile> getUserProfile() async {
    return await _client.getProfile();
  }
  
  Stream<ChatMessage> startChatMonitoring() async* {
    final monitor = ChatMonitor(accessToken: await _getAccessToken());
    await monitor.start();
    
    yield* monitor.messages;
  }
}
''');
}
