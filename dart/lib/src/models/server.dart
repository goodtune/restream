import 'package:json_annotation/json_annotation.dart';

part 'server.g.dart';

/// Ingest server information from /server/all endpoint.
@JsonSerializable()
class Server {
  /// Server ID.
  final int id;

  /// Server name/identifier.
  final String name;

  /// Server URL.
  final String url;

  /// RTMP URL for streaming.
  final String rtmpUrl;

  /// Server latitude coordinate.
  final String latitude;

  /// Server longitude coordinate.
  final String longitude;

  const Server({
    required this.id,
    required this.name,
    required this.url,
    required this.rtmpUrl,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a Server from JSON data.
  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

  /// Converts this Server to JSON.
  Map<String, dynamic> toJson() => _$ServerToJson(this);

  @override
  String toString() {
    return 'Server: $name\n'
        '  ID: $id\n'
        '  URL: $url\n'
        '  RTMP URL: $rtmpUrl\n'
        '  Location: $latitude, $longitude';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Server && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
