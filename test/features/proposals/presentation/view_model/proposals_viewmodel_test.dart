import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/usecases/get_post_usecase.dart';
import 'package:skillswap/features/proposals/domain/entities/proposal_entity.dart';
import 'package:skillswap/features/proposals/domain/usecases/accept_proposal_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/get_proposals_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/reject_proposal_usecase.dart';
import 'package:skillswap/features/proposals/domain/usecases/submit_proposal_complete_usecase.dart';
import 'package:skillswap/features/proposals/presentation/view_model/proposals_viewmodel.dart';

class MockGetProposalsUsecase extends Mock implements GetProposalsUsecase {}

class MockAcceptProposalUsecase extends Mock implements AcceptProposalUsecase {}

class MockRejectProposalUsecase extends Mock implements RejectProposalUsecase {}

class MockSubmitProposalCompleteUsecase extends Mock
    implements SubmitProposalCompleteUsecase {}

class MockGetPostByIdUsecase extends Mock implements GetPostByIdUsecase {}

class FakeGetProposalsParams extends Fake implements GetProposalsParams {}

class FakeAcceptProposalParams extends Fake implements AcceptProposalParams {}

class FakeRejectProposalParams extends Fake implements RejectProposalParams {}

class FakeSubmitProposalCompleteParams extends Fake
    implements SubmitProposalCompleteParams {}

class FakeGetPostByIdParams extends Fake implements GetPostByIdParams {}

const testAuthEntity = AuthEntity(
  authId: 'user1',
  email: 'test@test.com',
  username: 'testuser',
  fullName: 'Test User',
);

final testProposalEntity = ProposalEntity(
  id: 'proposal1',
  sender: const AuthEntity(
    authId: 'user1',
    email: 'sender@test.com',
    username: 'sender',
    fullName: 'Sender User',
  ),
  receiver: const AuthEntity(
    authId: 'user2',
    email: 'receiver@test.com',
    username: 'receiver',
    fullName: 'Receiver User',
  ),
  post: PostEntity(
    id: 'post1',
    title: 'Test Post',
    description: 'Test Description',
    requirements: ['req1'],
    tag: 'programming',
    locationType: 'remote',
    availability: 'full-time',
    duration: '1 month',
    userId: 'user2',
    username: 'user2',
  ),
  message: 'Hello, I would like to collaborate',
  status: 'pending',
);

void main() {
  late ProviderContainer container;
  late MockGetProposalsUsecase mockGetProposalsUsecase;
  late MockAcceptProposalUsecase mockAcceptProposalUsecase;
  late MockRejectProposalUsecase mockRejectProposalUsecase;
  late MockSubmitProposalCompleteUsecase mockSubmitProposalCompleteUsecase;
  late MockGetPostByIdUsecase mockGetPostByIdUsecase;

  setUpAll(() {
    registerFallbackValue(FakeGetProposalsParams());
    registerFallbackValue(FakeAcceptProposalParams());
    registerFallbackValue(FakeRejectProposalParams());
    registerFallbackValue(FakeSubmitProposalCompleteParams());
    registerFallbackValue(FakeGetPostByIdParams());
  });

  setUp(() {
    mockGetProposalsUsecase = MockGetProposalsUsecase();
    mockAcceptProposalUsecase = MockAcceptProposalUsecase();
    mockRejectProposalUsecase = MockRejectProposalUsecase();
    mockSubmitProposalCompleteUsecase = MockSubmitProposalCompleteUsecase();
    mockGetPostByIdUsecase = MockGetPostByIdUsecase();

    container = ProviderContainer(
      overrides: [
        getProposalsUsecaseProvider.overrideWithValue(mockGetProposalsUsecase),
        acceptProposalUsecaseProvider.overrideWithValue(
          mockAcceptProposalUsecase,
        ),
        rejectProposalUsecaseProvider.overrideWithValue(
          mockRejectProposalUsecase,
        ),
        submitProposalCompleteUsecaseProvider.overrideWithValue(
          mockSubmitProposalCompleteUsecase,
        ),
        getPostByIdUsecaseProvider.overrideWithValue(mockGetPostByIdUsecase),
        authViewModelProvider.overrideWith(() => TestAuthNotifier()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProposalsViewModel', () {
    group('build (initial fetch)', () {
      test('loads proposals successfully', () async {
        when(
          () => mockGetProposalsUsecase(any()),
        ).thenAnswer((_) async => Right([testProposalEntity]));

        final state = await container.read(proposalsViewModelProvider.future);

        expect(state, equals([testProposalEntity]));
        verify(() => mockGetProposalsUsecase(any())).called(1);
      });

      test('throws exception when user is not authenticated', () async {
        container.dispose();
        container = ProviderContainer(
          overrides: [
            getProposalsUsecaseProvider.overrideWithValue(
              mockGetProposalsUsecase,
            ),
            acceptProposalUsecaseProvider.overrideWithValue(
              mockAcceptProposalUsecase,
            ),
            rejectProposalUsecaseProvider.overrideWithValue(
              mockRejectProposalUsecase,
            ),
            submitProposalCompleteUsecaseProvider.overrideWithValue(
              mockSubmitProposalCompleteUsecase,
            ),
            getPostByIdUsecaseProvider.overrideWithValue(
              mockGetPostByIdUsecase,
            ),
            authViewModelProvider.overrideWith(() => TestAuthNotifierNoUser()),
          ],
        );

        expect(
          () => container.read(proposalsViewModelProvider.future),
          throwsException,
        );
      });
    });

    group('acceptProposal', () {
      test('updates proposal status to accepted', () async {
        when(
          () => mockGetProposalsUsecase(any()),
        ).thenAnswer((_) async => Right([testProposalEntity]));
        final acceptedProposal = ProposalEntity(
          id: 'proposal1',
          sender: testProposalEntity.sender,
          receiver: testProposalEntity.receiver,
          post: testProposalEntity.post,
          message: testProposalEntity.message,
          status: 'accepted',
        );
        when(
          () => mockAcceptProposalUsecase(any()),
        ).thenAnswer((_) async => Right(acceptedProposal));

        await container.read(proposalsViewModelProvider.future);
        await container
            .read(proposalsViewModelProvider.notifier)
            .acceptProposal('proposal1');

        final state = container.read(proposalsViewModelProvider).value;
        expect(state?.first.status, equals('accepted'));
        verify(() => mockAcceptProposalUsecase(any())).called(1);
      });
    });

    group('rejectProposal', () {
      test('updates proposal status to rejected', () async {
        when(
          () => mockGetProposalsUsecase(any()),
        ).thenAnswer((_) async => Right([testProposalEntity]));
        final rejectedProposal = ProposalEntity(
          id: 'proposal1',
          sender: testProposalEntity.sender,
          receiver: testProposalEntity.receiver,
          post: testProposalEntity.post,
          message: testProposalEntity.message,
          status: 'rejected',
        );
        when(
          () => mockRejectProposalUsecase(any()),
        ).thenAnswer((_) async => Right(rejectedProposal));

        await container.read(proposalsViewModelProvider.future);
        await container
            .read(proposalsViewModelProvider.notifier)
            .rejectProposal('proposal1');

        final state = container.read(proposalsViewModelProvider).value;
        expect(state?.first.status, equals('rejected'));
        verify(() => mockRejectProposalUsecase(any())).called(1);
      });
    });
  });
}

class TestAuthNotifier extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      authEntity: testAuthEntity,
    );
  }
}

class TestAuthNotifierNoUser extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }
}
