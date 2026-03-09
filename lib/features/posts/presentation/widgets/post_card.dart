import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skillswap/utils/my_colors.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String author;
  final List<String> tag;
  final String imagePath;
  final String? postId;
  final String? userProfilePicture;
  final VoidCallback? onTap;
  const PostCard({
    super.key,
    this.title = "",
    this.author = "",
    this.tag = const [],
    this.imagePath = "",
    this.postId,
    this.userProfilePicture,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: imagePath.isNotEmpty && imagePath.startsWith('http')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: imagePath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        userProfilePicture != null &&
                            userProfilePicture!.isNotEmpty &&
                            userProfilePicture!.startsWith('http')
                        ? CachedNetworkImageProvider(userProfilePicture!)
                        : null,
                    child:
                        userProfilePicture == null ||
                            userProfilePicture!.isEmpty ||
                            !userProfilePicture!.startsWith('http')
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                        Wrap(
                          runSpacing: 2.0,
                          spacing: 2.0,
                          children: [
                            for (var item in tag)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                  vertical: 1.0,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.color2,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: MyColors.color5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
