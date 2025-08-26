import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/restream_config.dart';
import '../errors/restream_exceptions.dart';

/// Event types for chat monitoring.
enum ChatEventType {
  unknown,
  chatMessage,
  userJoin,
  userLeave,
  connectionStatus,
  heartbeat,
}

/// Chat event data from WebSocket.
class ChatEvent {
  final ChatEventType type;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  ChatEvent({
    required this.type,
    required this.action,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatEvent.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as String? ?? 'unknown';
    final payload = json['payload'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    final type = _parseEventType(action);
    
    return ChatEvent(
      type: type,
      action: action,
      payload: payload,
    );
  }

  static ChatEventType _parseEventType(String action) {
    switch (action.toLowerCase()) {
      case 'chat_message':
      case 'message':
        return ChatEventType.chatMessage;
      case 'user_join':
      case 'join':
        return ChatEventType.userJoin;
      case 'user_leave':
      case 'leave':
        return ChatEventType.userLeave;
      case 'connection_status':
      case 'status':
        return ChatEventType.connectionStatus;
      case 'heartbeat':
      case 'ping':
        return ChatEventType.heartbeat;
      default:
        return ChatEventType.unknown;
    }
  }

  /// Extract chat message information if this is a chat message event.
  ChatMessage? get chatMessage {
    if (type != ChatEventType.chatMessage) return null;
    
    try {
      return ChatMessage.fromPayload(payload);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ChatEvent{\n'
           '  type: $type,\n'
           '  action: $action,\n'
           '  payload: $payload,\n'
           '  timestamp: $timestamp\n'
           '}';
  }
}

/// Chat message data extracted from chat events.
class ChatMessage {
  final String id;
  final String username;
  final String message;
  final String platform;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.username,
    required this.message,
    required this.platform,
    required this.timestamp,
  });

  factory ChatMessage.fromPayload(Map<String, dynamic> payload) {
    final id = payload['id'] as String? ?? '';
    final username = payload['username'] as String? ?? 'Unknown';
    final message = payload['message'] as String? ?? '';
    final platform = payload['platform'] as String? ?? 'Unknown';
    
    // Try to parse timestamp from payload
    DateTime timestamp = DateTime.now();
    final timestampValue = payload['timestamp'];
    if (timestampValue is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
    } else if (timestampValue is String) {
      timestamp = DateTime.tryParse(timestampValue) ?? DateTime.now();
    }

    return ChatMessage(
      id: id,
      username: username,
      message: message,
      platform: platform,
      timestamp: timestamp,
    );
  }

  @override
  String toString() {
    return '[$platform] $username: $message';
  }
}

/// WebSocket monitor for real-time chat events.
class ChatMonitor {
  final String accessToken;
  final Duration? maxDuration;
  
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  final StreamController<ChatEvent> _eventController = 
      StreamController<ChatEvent>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();
  
  Timer? _durationTimer;
  bool _isConnected = false;

  ChatMonitor({
    required this.accessToken,
    this.maxDuration,
  });

  /// Stream of chat events.
  Stream<ChatEvent> get events => _eventController.stream;

  /// Stream of error messages.
  Stream<String> get errors => _errorController.stream;

  /// Stream of chat messages only.
  Stream<ChatMessage> get messages => events
      .where((event) => event.type == ChatEventType.chatMessage)
      .map((event) => event.chatMessage!);

  /// Whether the monitor is currently connected.
  bool get isConnected => _isConnected;

  /// Start monitoring chat events.
  Future<void> start() async {
    if (_isConnected) {
      throw WebSocketException('ChatMonitor is already connected');
    }

    try {
      final url = '${RestreamConfig.chatWebSocketUrl}?accessToken=$accessToken';
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _messageSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      _isConnected = true;

      // Set up duration timer if specified
      if (maxDuration != null) {
        _durationTimer = Timer(maxDuration!, () {
          stop();
        });
      }
    } catch (e) {
      throw WebSocketException('Failed to connect to chat WebSocket: $e');
    }
  }

  /// Stop monitoring.
  Future<void> stop() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    await _messageSubscription?.cancel();
    _messageSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    _isConnected = false;
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = ChatEvent.fromJson(data);
      _eventController.add(event);
    } catch (e) {
      _errorController.add('Failed to parse message: $e');
    }
  }

  void _handleError(dynamic error) {
    _errorController.add('WebSocket error: $error');
    _isConnected = false;
  }

  void _handleDone() {
    _isConnected = false;
  }

  /// Dispose of resources.
  Future<void> dispose() async {
    await stop();
    await _eventController.close();
    await _errorController.close();
  }
}