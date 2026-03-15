import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String userId;
  final String username;
  final String email;
  final String bio;
  final String profileImage;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final String role;
  final String status;
  final DateTime createdAt;

  const UserEntity({
    required this.userId,
    required this.username,
    required this.email,
    this.bio = '',
    this.profileImage = '',
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.role = 'user',
    this.status = 'active',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [userId];
}
