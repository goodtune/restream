import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

/// Channel information for streaming platforms.
@JsonSerializable()
class Channel {
  /// Channel ID.
  final int id;

  /// Channel name.
  final String name;

  /// Streaming platform ID.
  final int platformId;

  /// Whether the channel is active/enabled.
  final bool active;

  /// Channel URL if available.
  final String? url;

  const Channel({
    required this.id,
    required this.name,
    required this.platformId,
    required this.active,
    this.url,
  });

  /// Creates a Channel from JSON data.
  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  /// Converts this Channel to JSON.
  Map<String, dynamic> toJson() => _$ChannelToJson(this);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('Channel: $name')
      ..writeln('  ID: $id')
      ..writeln('  Platform ID: $platformId')
      ..writeln('  Active: ${active ? 'Yes' : 'No'}');

    if (url != null) {
      buffer.writeln('  URL: $url');
    }

    return buffer.toString().trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Channel metadata information.
@JsonSerializable()
class ChannelMeta {
  /// Channel ID.
  final int channelId;

  /// Stream title.
  final String title;

  /// Stream description.
  final String? description;

  const ChannelMeta({
    required this.channelId,
    required this.title,
    this.description,
  });

  /// Creates a ChannelMeta from JSON data.
  factory ChannelMeta.fromJson(Map<String, dynamic> json) =>
      _$ChannelMetaFromJson(json);

  /// Converts this ChannelMeta to JSON.
  Map<String, dynamic> toJson() => _$ChannelMetaToJson(this);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('Channel Meta:')
      ..writeln('  Channel ID: $channelId')
      ..writeln('  Title: $title');

    if (description != null && description!.isNotEmpty) {
      buffer.writeln('  Description: $description');
    }

    return buffer.toString().trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelMeta &&
          runtimeType == other.runtimeType &&
          channelId == other.channelId;

  @override
  int get hashCode => channelId.hashCode;
}
