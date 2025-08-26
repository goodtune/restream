import 'package:json_annotation/json_annotation.dart';

part 'platform_image.g.dart';

/// Platform image URLs.
@JsonSerializable()
class PlatformImage {
  /// PNG image URL.
  final String png;

  /// SVG image URL.
  final String svg;

  const PlatformImage({required this.png, required this.svg});

  /// Creates a PlatformImage from JSON data.
  factory PlatformImage.fromJson(Map<String, dynamic> json) =>
      _$PlatformImageFromJson(json);

  /// Converts this PlatformImage to JSON.
  Map<String, dynamic> toJson() => _$PlatformImageToJson(this);

  @override
  String toString() {
    return 'PNG: $png, SVG: $svg';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformImage &&
          runtimeType == other.runtimeType &&
          png == other.png &&
          svg == other.svg;

  @override
  int get hashCode => png.hashCode ^ svg.hashCode;
}
