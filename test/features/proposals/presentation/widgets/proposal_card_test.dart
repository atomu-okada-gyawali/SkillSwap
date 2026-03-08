import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';
import 'package:skillswap/features/proposals/presentation/widgets/proposal_card.dart';

class MockProposalsViewModel extends AsyncNotifier<List<ProposalEntity>>
    implements ProposalsViewModel {
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

  @override
  Future<List<ProposalEntity>> build() async => [];

  @override
  Future<void> refresh() async {}

  @override
  Future<void> acceptProposal(String id) async {}

  @override
  Future<void> rejectProposal(String id) async {}

  @override
  Future<void> createProposal({
    required String receiverId,
    required String postId,
    required String offeredSkill,
    required String message,
    required String proposedDate,
    required String proposedTime,
    required int durationMinutes,
  }) async {}
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
        proposalsViewModelProvider.overrideWith(() => MockProposalsViewModel()),
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
      expect(find.text('PENDING'), findsOneWidget);
    });
  });
}
// flutter pub run test_cov_console