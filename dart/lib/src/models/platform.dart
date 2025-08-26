import 'package:json_annotation/json_annotation.dart';

import 'platform_image.dart';

part 'platform.g.dart';

/// Streaming platform information from /platform/all endpoint.
@JsonSerializable()
class Platform {
  /// Platform ID.
  final int id;

  /// Platform name (e.g., 'youtube', 'twitch').
  final String name;

  /// Platform URL.
  final String url;

  /// Platform image URLs.
  final PlatformImage image;

  /// Alternative platform image URLs.
  final PlatformImage altImage;

  const Platform({
    required this.id,
    required this.name,
    required this.url,
    required this.image,
    required this.altImage,
  });

  /// Creates a Platform from JSON data.
  factory Platform.fromJson(Map<String, dynamic> json) =>
      _$PlatformFromJson(json);

  /// Converts this Platform to JSON.
  Map<String, dynamic> toJson() => _$PlatformToJson(this);

  @override
  String toString() {
    return 'Platform: $name\n'
        '  ID: $id\n'
        '  URL: $url\n'
        '  Image: $image\n'
        '  Alt Image: $altImage';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Platform && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
