import 'package:json_annotation/json_annotation.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class TagModel {
  final String? id;
  final String name;
  @JsonKey(name: 'tagImage')
  final String? tagImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TagModel({
    this.id,
    required this.name,
    this.tagImage,
    this.createdAt,
    this.updatedAt,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagModelToJson(this);
}
