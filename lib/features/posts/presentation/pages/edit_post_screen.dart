import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/features/auth/presentation/widgets/custom_field_text.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/features/tags/presentation/providers/tags_provider.dart';
import 'package:skillswap/utils/my_colors.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _requirementController = TextEditingController();

  String _locationType = 'remote';
  String _availability = 'flexible';
  List<String> _requirements = [];
  String? _selectedTag;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _locationTypes = ['remote', 'on-site', 'hybrid'];
  final List<String> _availabilityTypes = [
    'full-time',
    'part-time',
    'weekends',
    'flexible',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postsViewModelProvider.notifier).getPostById(widget.postId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  void _initializeForm(PostEntity post) {
    if (_isInitialized) return;
    _isInitialized = true;

    _titleController.text = post.title;
    _descriptionController.text = post.description;
    _durationController.text = post.duration ?? '';
    _locationType = post.locationType;
    _availability = post.availability;
    _requirements = List.from(post.requirements);
    _selectedTag = post.tag;
    _existingImageUrl = post.postPhoto;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                    _existingImageUrl = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                    _existingImageUrl = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addRequirement() {
    final text = _requirementController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _requirements.add(text);
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(String req) {
    setState(() {
      _requirements.remove(req);
    });
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tagsAsync = ref.read(tagsProvider);
      String? tagId;
      if (_selectedTag != null) {
        final tags = tagsAsync.valueOrNull ?? [];
        final selectedTagObj = tags
            .where((t) => t.name == _selectedTag)
            .firstOrNull;
        tagId = selectedTagObj?.id;
      }

      await ref
          .read(postsViewModelProvider.notifier)
          .updatePost(
            postId: widget.postId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            requirements: _requirements,
            tag: tagId,
            locationType: _locationType,
            availability: _availability,
            duration: _durationController.text.trim().isEmpty
                ? null
                : _durationController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsViewModelProvider);
    final tagsAsync = ref.watch(tagsProvider);

    final selectedPost = postsState.selectedPost;

    if (postsState.status == PostStatus.loading && selectedPost == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Post'),
          backgroundColor: MyColors.color4,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (selectedPost == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Post'),
          backgroundColor: MyColors.color4,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${postsState.errorMessage ?? 'Post not found'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(postsViewModelProvider.notifier)
                    .getPostById(widget.postId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    _initializeForm(selectedPost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: MyColors.color4,
      ),
      body: _buildForm(tagsAsync),
    );
  }

  Widget _buildForm(AsyncValue tagsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          '${ApiEndpoints.baseUrl}${_existingImageUrl}',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to change photo',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Title',
              hint: 'Enter post title',
              controller: _titleController,
              prefixIcon: const Icon(Icons.title_outlined),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Description',
              hint: 'Describe your post',
              controller: _descriptionController,
              maxLines: 4,
              prefixIcon: const Icon(Icons.description_outlined),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _locationType,
              decoration: const InputDecoration(
                labelText: 'Location Type',
                border: OutlineInputBorder(),
              ),
              items: _locationTypes
                  .map<DropdownMenuItem<String>>(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _locationType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _availability,
              decoration: const InputDecoration(
                labelText: 'Availability',
                border: OutlineInputBorder(),
              ),
              items: _availabilityTypes
                  .map<DropdownMenuItem<String>>(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _availability = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Duration (optional)',
              hint: 'e.g., 2 hours/week',
              controller: _durationController,
              prefixIcon: const Icon(Icons.schedule_outlined),
            ),
            const SizedBox(height: 16),
            const Text(
              'Requirements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    label: 'Add requirement',
                    hint: 'Enter a requirement',
                    controller: _requirementController,
                    prefixIcon: const Icon(Icons.add_task_outlined),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addRequirement,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: MyColors.color5,
                    foregroundColor: MyColors.color1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _requirements
                  .map<Widget>(
                    (req) => Chip(
                      label: Text(req),
                      onDeleted: () => _removeRequirement(req),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            tagsAsync.when(
              data: (tags) {
                final selectedTagName = _selectedTag;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map<Widget>((tag) {
                    final isSelected =
                        selectedTagName != null && tag.name == selectedTagName;
                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTag = selected ? tag.name : null;
                        });
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading tags: $error'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.color5,
                  foregroundColor: MyColors.color1,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
