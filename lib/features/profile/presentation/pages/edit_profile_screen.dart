import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/auth/presentation/widgets/custom_field_text.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/utils/my_colors.dart';
import 'package:skillswap/core/api/api_endpoints.dart';

class EditProfileScreen extends ConsumerWidget {
  final AuthEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _EditProfileContent(user: user);
  }
}

class _EditProfileContent extends ConsumerStatefulWidget {
  final AuthEntity user;

  const _EditProfileContent({required this.user});

  @override
  ConsumerState<_EditProfileContent> createState() =>
      _EditProfileContentState();
}

class _EditProfileContentState extends ConsumerState<_EditProfileContent>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;
  late String? _currentProfilePicture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _currentProfilePicture = widget.user.profilePicture;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Photo',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MyColors.color1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: MyColors.color1, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fullName = _fullNameController.text.trim();

      await ref
          .read(authViewModelProvider.notifier)
          .updateProfile(
            fullName: fullName,
            profilePicture: _currentProfilePicture,
            newProfileImage: _selectedImage,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error updating profile: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverImageName = widget.user.profilePicture;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MyColors.color1,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: MyColors.color1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Profile Picture Section
                _buildProfilePictureSection(serverImageName),

                const SizedBox(height: 40),

                // Form Fields Section
                _buildFormFieldsSection(),

                const SizedBox(height: 40),

                // Additional Options Section
                _buildAdditionalOptions(),

                const SizedBox(height: 40),

                // Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(String? serverImageName) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MyColors.color1.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider
                      : (serverImageName != null && serverImageName.isNotEmpty)
                      ? NetworkImage('${ApiEndpoints.baseUrl}$serverImageName')
                      : null,
                  child:
                      _selectedImage == null &&
                          (serverImageName == null || serverImageName.isEmpty)
                      ? Icon(Icons.person, size: 70, color: Colors.grey[400])
                      : null,
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColors.color1,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to change photo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFieldsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          CustomTextFormField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _fullNameController,
            prefixIcon: const Icon(Icons.person_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: widget.user.email,
            onTap: null, // Read-only
          ),
          const Divider(height: 1),
          _buildOptionTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: widget.user.phoneNumber ?? 'Not added',
            onTap: null, // Read-only for now
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: MyColors.color1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: MyColors.color1, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [MyColors.color1, MyColors.color1.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.color1.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
