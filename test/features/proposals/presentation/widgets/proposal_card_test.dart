import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/presentation/widgets/proposal_card.dart';

class TestProposalsViewModel extends ProposalsViewModelForTest {}

class ProposalsViewModelForTest extends ChangeNotifier {
  @override
  Future<PostEntity?> getPostById(String postId) async {
    return PostEntity(
      id: postId,
      title: 'Test Skill',
      description: 'Test Description',
      requirements: ['req1'],
      tag: 'programming',
      locationType: 'remote',
      availability: 'full-time',
      duration: '1 month',
      userId: 'user1',
      username: 'testuser',
    );
  }
}

void main() {
  const testSender = AuthEntity(
    authId: 'user1',
    email: 'sender@test.com',
    username: 'senderuser',
    fullName: 'Sender User',
  );

  const testReceiver = AuthEntity(
    authId: 'user2',
    email: 'receiver@test.com',
    username: 'receiveruser',
    fullName: 'Receiver User',
  );

  final testProposal = ProposalEntity(
    id: 'proposal1',
    sender: testSender,
    receiver: testReceiver,
    postId: 'post1',
    offeredSkillId: 'post2',
    message: 'Hello, I would like to collaborate with you',
    status: 'pending',
    createdAt: DateTime(2024, 1, 15),
  );

  Widget createTestWidget({required Widget child}) {
    return ProviderScope(
      overrides: [
        proposalsViewModelProviderForTestProvider.overrideWithValue(
          TestProposalsViewModel(),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('ProposalCard Widget', () {
    testWidgets('displays sender username', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: ProposalCard(proposal: testProposal)),
      );

      expect(find.text('From: senderuser'), findsOneWidget);
    });

    testWidgets('displays message preview', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: ProposalCard(proposal: testProposal)),
      );

      expect(
        find.text('Hello, I would like to collaborate with you'),
        findsOneWidget,
      );
    });

    testWidgets('displays status chip for pending status', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: ProposalCard(proposal: testProposal)),
      );

      await tester.pump();
      expect(find.text('pending'), findsOneWidget);
    });
  });
}
