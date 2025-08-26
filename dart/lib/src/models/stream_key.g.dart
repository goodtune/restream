// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamKey _$StreamKeyFromJson(Map<String, dynamic> json) => StreamKey(
  key: json['key'] as String,
  rtmpUrl: json['rtmpUrl'] as String,
  srtUrl: json['srtUrl'] as String?,
);

Map<String, dynamic> _$StreamKeyToJson(StreamKey instance) => <String, dynamic>{
  'key': instance.key,
  'rtmpUrl': instance.rtmpUrl,
  'srtUrl': instance.srtUrl,
};
