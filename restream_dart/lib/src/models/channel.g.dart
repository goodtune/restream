// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  platformId: (json['platformId'] as num).toInt(),
  active: json['active'] as bool,
  url: json['url'] as String?,
);

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'platformId': instance.platformId,
  'active': instance.active,
  'url': instance.url,
};

ChannelMeta _$ChannelMetaFromJson(Map<String, dynamic> json) => ChannelMeta(
  channelId: (json['channelId'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ChannelMetaToJson(ChannelMeta instance) =>
    <String, dynamic>{
      'channelId': instance.channelId,
      'title': instance.title,
      'description': instance.description,
    };
