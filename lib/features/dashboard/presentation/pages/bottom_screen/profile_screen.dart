import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/utils/my_colors.dart';
import 'package:skillswap/core/api/api_endpoints.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<XFile> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedMediaType;

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Denied"),
        content: Text("Please grant the necessary permissions from settings."),
        actions: [
          TextButton(onPressed: () {}, child: Text('Cancel')),
          TextButton(onPressed: () {}, child: Text('Open Settings')),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(XFile(photo.path));
        _selectedMediaType = 'photo';
      });
      //upload image to server
      await ref
          .read(authViewModelProvider.notifier)
          .uploadProfilePicture(photo: File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(XFile(image.path));
          _selectedMediaType = 'photo';
        });
        //upload image to server
        await ref
            .read(authViewModelProvider.notifier)
            .uploadProfilePicture(photo: File(image.path));
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred while picking from gallery.')),
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final serverImageName =
        authState.authEntity?.profilePicture ??
        authState.uploadPhotoName ??
        ref.read(userSessionServiceProvider).getCurrentUserProfilePicture();

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          spacing: 38,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: MyColors.color5,
              ),
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              foregroundColor: MyColors.color1,
                              radius: 45,
                              foregroundImage: _selectedMedia.isNotEmpty
                                  ? FileImage(File(_selectedMedia[0].path))
                                        as ImageProvider
                                  : (serverImageName != null &&
                                        serverImageName.isNotEmpty)
                                  ? NetworkImage(
                                      '${ApiEndpoints.baseUrl}auth/profile-image/$serverImageName',
                                    )
                                  : AssetImage(
                                      'assets/images/default-profile.jpg',
                                    ),
                            ),
                            Positioned(
                              bottom: -10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => {_pickMedia()},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: MyColors.color1,
                                    ),

                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Ramesh Chapagain",
                        style: TextStyle(
                          fontSize: 20,
                          color: MyColors.color1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                  Positioned(
                    bottom: -25,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(maxWidth: 300.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("have 3 skills"),
                            Text("12 skill exchanges"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Column(
                    spacing: 7,
                    children: [
                      MyBox(
                        icon: Icons.mail,
                        text: "rameshchapagain@gmail.com",
                      ),
                      MyBox(icon: Icons.pin_drop, text: "New Baneshwor"),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  MyBox(icon: Icons.logout, text: "Logout"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final String color;
  const MyBox({super.key, required this.icon, required this.text, this.color = 'white'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: MyColors.secondaryTextColor.withOpacity(
              0.2,
            ),
            offset: Offset(0, 5), 
            blurRadius: 3, 
            spreadRadius:
                1, 
          ),
        ],
        color: Colors.red,
        border: Border.all(color: MyColors.secondaryTextColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon),
          Text(text, style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
