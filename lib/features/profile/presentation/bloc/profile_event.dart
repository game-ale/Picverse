import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateBioRequested extends ProfileEvent {
  final String bio;
  const ProfileUpdateBioRequested({required this.bio});

  @override
  List<Object?> get props => [bio];
}

class ProfileUpdateUsernameRequested extends ProfileEvent {
  final String username;
  const ProfileUpdateUsernameRequested({required this.username});

  @override
  List<Object?> get props => [username];
}

class ProfileUpdateImageRequested extends ProfileEvent {
  final String imagePath;
  const ProfileUpdateImageRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class ProfileSaveRequested extends ProfileEvent {
  final String? username;
  final String? bio;
  final String? imagePath;

  const ProfileSaveRequested({
    this.username,
    this.bio,
    this.imagePath,
  });

  @override
  List<Object?> get props => [username, bio, imagePath];
}

class ProfileFollowToggled extends ProfileEvent {
  final String targetUserId;
  const ProfileFollowToggled({required this.targetUserId});

  @override
  List<Object?> get props => [targetUserId];
}

class ProfileFollowersRequested extends ProfileEvent {
  final String userId;
  const ProfileFollowersRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ProfileFollowingRequested extends ProfileEvent {
  final String userId;
  const ProfileFollowingRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
