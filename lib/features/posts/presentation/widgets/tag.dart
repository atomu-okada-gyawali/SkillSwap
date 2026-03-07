import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String imagePath;
  final String title;
  const Tag({
    super.key,
    this.imagePath = "assets/images/guitar.jpg",
    this.title = "Programming",
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     shape: BoxShape.circle,
            //     border: Border.all(color: Colors.grey.shade400),
            //   ),
            //   child: Image(image: AssetImage(imagePath), width: 25, height: 25),
            // ),
            CircleAvatar(backgroundImage: AssetImage(imagePath), radius: 12),
            SizedBox(width: 11),
            Text(title),
          ],
        ),
      ),
    );
  }
}
