// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trait_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraitModel _$TraitModelFromJson(Map<String, dynamic> json) => TraitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconData: json['icon_data'] as String,
      value: json['value'] as String,
      category: json['category'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
    );

Map<String, dynamic> _$TraitModelToJson(TraitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon_data': instance.iconData,
      'value': instance.value,
      'category': instance.category,
      'displayOrder': instance.displayOrder,
    };
