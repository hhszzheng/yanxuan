// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sceneLightShoppingGuideModule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SceneLightShoppingGuideModule _$SceneLightShoppingGuideModuleFromJson(
    Map<String, dynamic> json) {
  return SceneLightShoppingGuideModule()
    ..styleItem = json['styleItem'] == null
        ? null
        : StyleItem.fromJson(json['styleItem'] as Map<String, dynamic>);
}

Map<String, dynamic> _$SceneLightShoppingGuideModuleToJson(
        SceneLightShoppingGuideModule instance) =>
    <String, dynamic>{
      'styleItem': instance.styleItem,
    };
