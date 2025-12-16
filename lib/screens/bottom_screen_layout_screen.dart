import 'package:flutter/material.dart';
import 'package:skillswap/screens/bottom_screen/explore_screen.dart';
import 'package:skillswap/screens/bottom_screen/message_screen.dart';
import 'package:skillswap/screens/bottom_screen/profile_screen.dart';
import 'package:skillswap/screens/bottom_screen/proposal_screen.dart';

class BottomScreenLayoutScreen extends StatefulWidget {
  const BottomScreenLayoutScreen({super.key});

  @override
  State<BottomScreenLayoutScreen> createState() =>
      _BottomScreenLayoutScreenState();
}

class _BottomScreenLayoutScreenState extends State<BottomScreenLayoutScreen> {
  int _selectedIndex = 0;
  List<Widget> lstBottomScreen = [
    const ExploreScreen(),
    const ProposalScreen(),
    const MessageScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: lstBottomScreen[_selectedIndex],
      floatingActionButton: FloatingActionButton(onPressed: (){},child: Icon(Icons.add),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.front_hand_rounded),
            label: 'Proposals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Messages',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: Colors.amber,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
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
