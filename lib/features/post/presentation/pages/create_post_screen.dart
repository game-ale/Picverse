import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/widgets/primary_button.dart';
import 'package:picverse/features/post/presentation/bloc/post_bloc.dart';
import 'package:picverse/features/post/presentation/bloc/post_event.dart';
import 'package:picverse/features/post/presentation/bloc/post_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  String? _imagePath;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _onPost() {
    if (_imagePath == null) return;
    context.read<PostBloc>().add(
      PostCreateRequested(
        imagePath: _imagePath!,
        caption: _captionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocListener<PostBloc, PostState>(
        listener: (context, state) {
          if (state.status == PostStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Post shared!')));
            context.go('/');
          }
          if (state.status == PostStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to post'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image preview / picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.cardDarkBorder
                          : AppColors.grey200,
                    ),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 64,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to select a photo',
                              style: TextStyle(
                                color: AppColors.grey500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Caption
              TextField(
                controller: _captionController,
                maxLines: 4,
                maxLength: 2200,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  hintStyle: TextStyle(color: AppColors.grey500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.cardDarkBorder
                          : AppColors.grey200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.cardDarkBorder
                          : AppColors.grey200,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'Share Post',
                    isLoading: state.status == PostStatus.loading,
                    onPressed: _imagePath != null ? _onPost : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
