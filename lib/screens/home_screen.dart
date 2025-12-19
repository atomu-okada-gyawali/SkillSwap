import 'package:flutter/material.dart';
import 'package:skillswap/screens/bottom_screen/explore_screen.dart';
import 'package:skillswap/screens/bottom_screen/message_screen.dart';
import 'package:skillswap/screens/bottom_screen/profile_screen.dart';
import 'package:skillswap/screens/bottom_screen/proposal_screen.dart';
import 'package:skillswap/utils/my_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> lstBottomScreen = [
    ExploreScreen(),
    const ProposalScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: lstBottomScreen[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.color5,
        foregroundColor: MyColors.color1,
        shape: CircleBorder(),
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.front_hand_rounded),
            label: 'Proposals',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: MyColors.color4,
        selectedItemColor: MyColors.color1,
        unselectedItemColor: MyColors.color2,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
