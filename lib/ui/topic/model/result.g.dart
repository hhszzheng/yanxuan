// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map<String, dynamic> json) {
  return Result()
    ..topics = (json['topics'] as List)
        ?.map((e) =>
            e == null ? null : TopicItem.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'topics': instance.topics,
    };
