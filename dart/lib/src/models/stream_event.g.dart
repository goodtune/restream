// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamEvent _$StreamEventFromJson(Map<String, dynamic> json) => StreamEvent(
  id: json['id'] as String,
  showId: json['showId'] as String?,
  status: json['status'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  isInstant: json['isInstant'] as bool,
  isRecordOnly: json['isRecordOnly'] as bool,
  coverUrl: json['coverUrl'] as String?,
  scheduledFor: (json['scheduledFor'] as num?)?.toInt(),
  startedAt: (json['startedAt'] as num?)?.toInt(),
  finishedAt: (json['finishedAt'] as num?)?.toInt(),
  destinations: (json['destinations'] as List<dynamic>)
      .map((e) => EventDestination.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StreamEventToJson(StreamEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'showId': instance.showId,
      'status': instance.status,
      'title': instance.title,
      'description': instance.description,
      'isInstant': instance.isInstant,
      'isRecordOnly': instance.isRecordOnly,
      'coverUrl': instance.coverUrl,
      'scheduledFor': instance.scheduledFor,
      'startedAt': instance.startedAt,
      'finishedAt': instance.finishedAt,
      'destinations': instance.destinations,
    };
