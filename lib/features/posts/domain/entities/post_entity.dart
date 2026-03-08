import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String? postPhoto;
  final List<String> requirements;
  final String? tag;
  final String locationType;
  final String availability;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // user-related information populated from backend
  final String? userId;
  final String? username;
  final String? userProfilePicture;

  const PostEntity({
    this.id,
    required this.title,
    required this.description,
    this.postPhoto,
    required this.requirements,
    this.tag,
    required this.locationType,
    required this.availability,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.username,
    this.userProfilePicture,
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
    userId,
    username,
    userProfilePicture,
  ];
}
