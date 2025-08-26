// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDestination _$EventDestinationFromJson(Map<String, dynamic> json) =>
    EventDestination(
      channelId: (json['channelId'] as num).toInt(),
      externalUrl: json['externalUrl'] as String?,
      streamingPlatformId: (json['streamingPlatformId'] as num).toInt(),
    );

Map<String, dynamic> _$EventDestinationToJson(EventDestination instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'externalUrl': instance.externalUrl,
      'streamingPlatformId': instance.streamingPlatformId,
    };
