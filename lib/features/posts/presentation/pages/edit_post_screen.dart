import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/features/posts/data/models/post_model.dart';
import 'package:skillswap/features/posts/data/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/presentation/providers/posts_provider.dart';
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
  List<String> _selectedTags = [];
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _locationTypes = ['remote', 'onsite', 'hybrid'];
  final List<String> _availabilityTypes = [
    'full-time',
    'part-time',
    'weekends',
    'flexible',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  void _initializeForm(PostModel post) {
    if (_isInitialized) return;
    _isInitialized = true;

    _titleController.text = post.title;
    _descriptionController.text = post.description;
    _durationController.text = post.duration ?? '';
    _locationType = post.locationType;
    _availability = post.availability;
    _requirements = List.from(post.requirements);
    _selectedTags = List.from(post.tag);
    _existingImageUrl = post.postPhoto;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _existingImageUrl = null;
      });
    }
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

    setState(() {
      _isLoading = true;
    });

    try {
      final post = PostModel(
        id: widget.postId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirements,
        tag: _selectedTags,
        locationType: _locationType,
        availability: _availability,
        duration: _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
        postPhoto: _existingImageUrl,
      );

      final repository = ref.read(postsRepositoryProvider);
      final result = await repository.updatePost(widget.postId, post);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (updatedPost) {
          ref.invalidate(selectedPostProvider(widget.postId));
          ref.invalidate(postsProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post updated successfully!')),
            );
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(selectedPostProvider(widget.postId));
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: MyColors.color4,
      ),
      body: postAsync.when(
        data: (post) {
          _initializeForm(post);
          return _buildForm(tagsAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(selectedPostProvider(widget.postId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
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
                          _existingImageUrl!,
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
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
                  .map(
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
                  .map(
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
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., 2 hours/week',
              ),
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
                  child: TextFormField(
                    controller: _requirementController,
                    decoration: const InputDecoration(
                      labelText: 'Add requirement',
                      border: OutlineInputBorder(),
                    ),
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
                  .map(
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
              data: (tags) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final isSelected = _selectedTags.contains(tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag.id!);
                        } else {
                          _selectedTags.remove(tag.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
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
