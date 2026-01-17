import 'package:flutter/material.dart';
import 'package:skillswap/features/dashboard/presentation/widgets/post_card.dart';
import 'package:skillswap/features/dashboard/presentation/widgets/tag.dart';
import 'package:skillswap/features/dashboard/presentation/widgets/welcome_card.dart';
import 'package:skillswap/utils/my_colors.dart';

class PostModel {
  String title;
  String author;
  List<String> wantsToLearn;
  String imagePath;

  PostModel({
    required this.title,
    required this.author,
    required this.wantsToLearn,
    required this.imagePath,
  });
}

class TagModel {
  String title;
  String imagePath;
  TagModel({required this.title, required this.imagePath});
}

class ExploreScreen extends StatefulWidget {
  ExploreScreen({super.key});
  final List<PostModel> _posts = [
    PostModel(
      title: "Looking to learn React",
      author: "Aayush",
      wantsToLearn: ["React", "JavaScript", "Frontend"],
      imagePath: "assets/images/guitar.jpg",
    ),
    PostModel(
      title: "Want to master Flutter",
      author: "Suman",
      wantsToLearn: ["Flutter", "Dart", "Mobile Development"],
      imagePath: "assets/images/guitar.jpg",
    ),
    PostModel(
      title: "Interested in Backend Development",
      author: "Ritika",
      wantsToLearn: ["Node.js", "Express", "MongoDB"],
      imagePath: "assets/images/guitar.jpg",
    ),
    PostModel(
      title: "Learning UI/UX Design",
      author: "Nischal",
      wantsToLearn: ["Figma", "UI Design", "UX Research"],
      imagePath: "assets/images/guitar.jpg",
    ),
    PostModel(
      title: "Getting started with Data Science",
      author: "Prabin",
      wantsToLearn: ["Python", "Pandas", "Machine Learning"],
      imagePath: "assets/images/guitar.jpg",
    ),
  ];

  final List<TagModel> tags = [
    TagModel(title: "Programming", imagePath: "assets/images/guitar.jpg"),
    TagModel(title: "Design", imagePath: "assets/images/guitar.jpg"),
    TagModel(title: "Music", imagePath: "assets/images/guitar.jpg"),
    TagModel(title: "Art", imagePath: "assets/images/guitar.jpg"),
    TagModel(title: "Cooking", imagePath: "assets/images/guitar.jpg"),
  ];
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        color: MyColors.color1,
        child: Column(
          children: [
            WelcomeCard(),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,

                itemCount: widget.tags.length,
                itemBuilder: (BuildContext context, int index) {
                  return Tag(
                    imagePath: widget.tags[index].imagePath,
                    title: widget.tags[index].title,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: 8);
                },
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: widget._posts.length,
                itemBuilder: (BuildContext context, int index) {
                  String title = widget._posts[index].title;
                  String author = widget._posts[index].author;
                  List<String> wantsToLearn = widget._posts[index].wantsToLearn;
                  String imagePath = widget._posts[index].imagePath;

                  return PostCard(
                    title: title,
                    author: author,
                    wantsToLearn: wantsToLearn,
                    imagePath: imagePath,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
