import 'package:json_annotation/json_annotation.dart';

part 'event_destination.g.dart';

/// Event destination information representing where a stream is broadcast.
@JsonSerializable()
class EventDestination {
  /// Channel ID for the destination.
  final int channelId;

  /// External URL if available (e.g., YouTube watch URL).
  final String? externalUrl;

  /// Streaming platform ID.
  final int streamingPlatformId;

  const EventDestination({
    required this.channelId,
    this.externalUrl,
    required this.streamingPlatformId,
  });

  /// Creates an EventDestination from JSON data.
  factory EventDestination.fromJson(Map<String, dynamic> json) =>
      _$EventDestinationFromJson(json);

  /// Converts this EventDestination to JSON.
  Map<String, dynamic> toJson() => _$EventDestinationToJson(this);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('Channel ID: $channelId')
      ..writeln('Platform ID: $streamingPlatformId');

    if (externalUrl != null) {
      buffer.writeln('External URL: $externalUrl');
    }

    return buffer.toString().trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDestination &&
          runtimeType == other.runtimeType &&
          channelId == other.channelId &&
          externalUrl == other.externalUrl &&
          streamingPlatformId == other.streamingPlatformId;

  @override
  int get hashCode =>
      channelId.hashCode ^ externalUrl.hashCode ^ streamingPlatformId.hashCode;
}
