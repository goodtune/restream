// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Platform _$PlatformFromJson(Map<String, dynamic> json) => Platform(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  url: json['url'] as String,
  image: PlatformImage.fromJson(json['image'] as Map<String, dynamic>),
  altImage: PlatformImage.fromJson(json['altImage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlatformToJson(Platform instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'image': instance.image,
  'altImage': instance.altImage,
};
