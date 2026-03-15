import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:picverse/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.username,
    required super.email,
    super.bio,
    super.profileImage,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.role,
    super.status,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      profileImage: data['profileImage'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'bio': bio,
      'profileImage': profileImage,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'role': role,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? bio,
    String? profileImage,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    String? role,
    String? status,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
