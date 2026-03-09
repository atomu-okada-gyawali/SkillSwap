class Tag {
  final String? id;
  final String name;
  final String? tagImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tag({
    this.id,
    required this.name,
    this.tagImage,
    this.createdAt,
    this.updatedAt,
  });
}
