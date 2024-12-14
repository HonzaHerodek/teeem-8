import 'package:json_annotation/json_annotation.dart';

part 'step_type_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StepTypeOption {
  final String id;
  final String label;
  final String type; // e.g., 'text', 'select', 'number'
  final Map<String, dynamic>? config; // Additional configuration for the option

  StepTypeOption({
    required this.id,
    required this.label,
    required this.type,
    this.config,
  });

  factory StepTypeOption.fromJson(Map<String, dynamic> json) =>
      _$StepTypeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$StepTypeOptionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StepTypeModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  @JsonKey(required: true)  // Explicitly mark color as required for JSON
  final String color;
  final List<StepTypeOption> options;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  StepTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.options,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory StepTypeModel.fromJson(Map<String, dynamic> json) =>
      _$StepTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$StepTypeModelToJson(this);
}
