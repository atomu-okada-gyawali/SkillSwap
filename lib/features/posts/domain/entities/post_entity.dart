import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String? postPhoto;
  final List<String> requirements;
  final String tag;
  final String locationType;
  final String availability;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? user;

  const PostEntity({
    this.id,
    required this.title,
    required this.description,
    this.postPhoto,
    required this.requirements,
    required this.tag,
    required this.locationType,
    required this.availability,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    postPhoto,
    requirements,
    tag,
    locationType,
    availability,
    duration,
    createdAt,
    updatedAt,
    user,
  ];
}
