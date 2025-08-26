import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/restream_config.dart';
import '../errors/restream_exceptions.dart';

/// Event types for streaming monitoring.
enum StreamingEventType {
  unknown,
  streamStart,
  streamStop,
  connectionStatus,
  metrics,
}

/// Streaming event data from WebSocket.
class StreamingEvent {
  final StreamingEventType type;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  StreamingEvent({
    required this.type,
    required this.action,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory StreamingEvent.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as String? ?? 'unknown';
    final payload = json['payload'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    final type = _parseEventType(action);
    
    return StreamingEvent(
      type: type,
      action: action,
      payload: payload,
    );
  }

  static StreamingEventType _parseEventType(String action) {
    switch (action.toLowerCase()) {
      case 'stream_start':
      case 'start':
        return StreamingEventType.streamStart;
      case 'stream_stop':
      case 'stop':
        return StreamingEventType.streamStop;
      case 'connection_status':
      case 'status':
        return StreamingEventType.connectionStatus;
      case 'metrics':
      case 'stats':
        return StreamingEventType.metrics;
      default:
        return StreamingEventType.unknown;
    }
  }

  @override
  String toString() {
    return 'StreamingEvent{\n'
           '  type: $type,\n'
           '  action: $action,\n'
           '  payload: $payload,\n'
           '  timestamp: $timestamp\n'
           '}';
  }
}

/// WebSocket monitor for real-time streaming events.
class StreamingMonitor {
  final String accessToken;
  final Duration? maxDuration;
  
  WebSocketChannel? _channel;
  StreamSubscription? _messageSubscription;
  final StreamController<StreamingEvent> _eventController = 
      StreamController<StreamingEvent>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();
  
  Timer? _durationTimer;
  bool _isConnected = false;

  StreamingMonitor({
    required this.accessToken,
    this.maxDuration,
  });

  /// Stream of streaming events.
  Stream<StreamingEvent> get events => _eventController.stream;

  /// Stream of error messages.
  Stream<String> get errors => _errorController.stream;

  /// Whether the monitor is currently connected.
  bool get isConnected => _isConnected;

  /// Start monitoring streaming events.
  Future<void> start() async {
    if (_isConnected) {
      throw WebSocketException('StreamingMonitor is already connected');
    }

    try {
      final url = '${RestreamConfig.streamingWebSocketUrl}?accessToken=$accessToken';
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
      throw WebSocketException('Failed to connect to streaming WebSocket: $e');
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
      final event = StreamingEvent.fromJson(data);
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