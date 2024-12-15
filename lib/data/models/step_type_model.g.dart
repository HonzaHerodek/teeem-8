// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepTypeOption _$StepTypeOptionFromJson(Map<String, dynamic> json) =>
    StepTypeOption(
      id: json['id'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      config: json['config'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$StepTypeOptionToJson(StepTypeOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'type': instance.type,
      'config': instance.config,
    };

StepTypeModel _$StepTypeModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['color'],
  );
  return StepTypeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    icon: json['icon'] as String,
    color: json['color'] as String,
    options: (json['options'] as List<dynamic>)
        .map((e) => StepTypeOption.fromJson(e as Map<String, dynamic>))
        .toList(),
    metadata: json['metadata'] as Map<String, dynamic>?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );
}

Map<String, dynamic> _$StepTypeModelToJson(StepTypeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'color': instance.color,
      'options': instance.options.map((e) => e.toJson()).toList(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
