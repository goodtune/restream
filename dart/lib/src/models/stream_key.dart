import 'package:json_annotation/json_annotation.dart';

part 'stream_key.g.dart';

/// Stream key information for RTMP streaming.
@JsonSerializable()
class StreamKey {
  /// The stream key/token.
  final String key;

  /// RTMP URL for streaming.
  final String rtmpUrl;

  /// SRT URL for streaming (if available).
  final String? srtUrl;

  const StreamKey({required this.key, required this.rtmpUrl, this.srtUrl});

  /// Creates a StreamKey from JSON data.
  factory StreamKey.fromJson(Map<String, dynamic> json) =>
      _$StreamKeyFromJson(json);

  /// Converts this StreamKey to JSON.
  Map<String, dynamic> toJson() => _$StreamKeyToJson(this);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('Stream Key Information:')
      ..writeln('  Key: ${_maskKey(key)}')
      ..writeln('  RTMP URL: $rtmpUrl');

    if (srtUrl != null) {
      buffer.writeln('  SRT URL: $srtUrl');
    }

    return buffer.toString().trim();
  }

  /// Masks the stream key for security, showing only the first 8 characters.
  String _maskKey(String key) {
    if (key.length <= 8) return key;
    return '${key.substring(0, 8)}${'*' * (key.length - 8)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamKey &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          rtmpUrl == other.rtmpUrl &&
          srtUrl == other.srtUrl;

  @override
  int get hashCode => key.hashCode ^ rtmpUrl.hashCode ^ srtUrl.hashCode;
}
