import 'package:flutter/material.dart';
import 'package:skillswap/utils/my_colors.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: MyColors.color4,
      child: Padding(
        padding: EdgeInsets.all(16.0),

        child: Column(
          spacing: 15.0,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                Expanded(
                  child: Text(
                    "Hello Ramesh",
                    style: TextStyle(fontSize: 20, color: MyColors.color1),
                  ),
                ),
                Container(
                  height: 30,
                  width: 30,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: MyColors.color1,
                    size: 30,
                  ),
                ),
                CircleAvatar(),
              ],
            ),
            SearchBar(hintText: "Search skills..."),
          ],
        ),
      ),
    );
  }
}
