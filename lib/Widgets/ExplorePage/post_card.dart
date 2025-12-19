import 'package:flutter/material.dart';
import 'package:skillswap/utils/my_colors.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String author;
  final List<String> wantsToLearn;
  final String imagePath;
  const PostCard({
    super.key,
    this.title = "",
    this.author = "",
    this.wantsToLearn = const [],
    this.imagePath = "",
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerRight,
              width: double.infinity,
              child: Icon(Icons.favorite_outline),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[200]!),
              ),
              clipBehavior: Clip.hardEdge,
              child: AspectRatio(
                aspectRatio: 131 / 141,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            Row(
              children: [
                const CircleAvatar(),
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
                          for (var item in wantsToLearn)
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
    );
  }
}
