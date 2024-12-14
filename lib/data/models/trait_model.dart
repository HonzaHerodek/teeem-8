import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'trait_model.g.dart';

@immutable
@JsonSerializable()
class TraitModel {
  final String id;
  final String name;
  @JsonKey(name: 'icon_data')
  final String iconData;
  final String value;
  @JsonKey(defaultValue: '')
  final String category;
  @JsonKey(defaultValue: 0)
  final int displayOrder;

  const TraitModel({
    required this.id,
    required this.name,
    required this.iconData,
    required this.value,
    required this.category,
    required this.displayOrder,
  });

  factory TraitModel.fromJson(Map<String, dynamic> json) =>
      _$TraitModelFromJson(json);

  Map<String, dynamic> toJson() => _$TraitModelToJson(this);

  TraitModel copyWith({
    String? id,
    String? name,
    String? iconData,
    String? value,
    String? category,
    int? displayOrder,
  }) {
    return TraitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      value: value ?? this.value,
      category: category ?? this.category,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TraitModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          iconData == other.iconData &&
          value == value &&
          category == category &&
          displayOrder == displayOrder;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      iconData.hashCode ^
      value.hashCode ^
      category.hashCode ^
      displayOrder.hashCode;
}
