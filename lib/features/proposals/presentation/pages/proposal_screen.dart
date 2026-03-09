import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/utils/my_colors.dart';

class ProposalScreen extends ConsumerWidget {
  const ProposalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: SizedBox.expand(
        child: Column(
          children: [
            Container(
              color: MyColors.color4,
              child: const TabBar(
                labelColor: MyColors.color1,
                unselectedLabelColor: MyColors.color2,
                indicatorColor: MyColors.color1,
                tabs: [
                  Tab(text: 'Sent'),
                  Tab(text: 'Received'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
