import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/widgets/primary_button.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_event.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _newImagePath;
  bool _inited = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final state = context.read<ProfileBloc>().state;
      _usernameController = TextEditingController(
        text: state.user?.username ?? '',
      );
      _bioController = TextEditingController(text: state.user?.bio ?? '');
      _inited = true;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _newImagePath = picked.path);
    }
  }

  void _onSave() {
    final state = context.read<ProfileBloc>().state;
    final user = state.user;
    if (user == null) return;

    final newUsername = _usernameController.text.trim();
    final newBio = _bioController.text.trim();
    final hasUsernameChange =
        newUsername.isNotEmpty && newUsername != user.username;
    final hasBioChange = newBio != user.bio;
    final hasImageChange = _newImagePath != null;

    if (!hasUsernameChange && !hasBioChange && !hasImageChange) {
      context.pop();
      return;
    }

    setState(() => _isSaving = true);
    context.read<ProfileBloc>().add(
      ProfileSaveRequested(
        username: hasUsernameChange ? newUsername : null,
        bio: hasBioChange ? newBio : null,
        imagePath: _newImagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (_isSaving && state.status == ProfileStatus.loaded) {
            context.pop();
            return;
          }
          if (state.status == ProfileStatus.error &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            if (mounted) {
              setState(() => _isSaving = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.grey200,
                        backgroundImage: _newImagePath != null
                            ? FileImage(File(_newImagePath!))
                            : (user.profileImage.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          user.profileImage,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child:
                            (_newImagePath == null && user.profileImage.isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 52,
                                color: AppColors.grey400,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryPurple,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Save',
                  isLoading: state.status == ProfileStatus.loading,
                  onPressed: _onSave,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
