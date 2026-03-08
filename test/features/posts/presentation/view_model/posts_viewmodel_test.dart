import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_all_posts_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/update_post_usecase.dart';
import 'package:skillswap/features/posts/presentation/state/post_state.dart';
import 'package:skillswap/features/posts/presentation/view_model/posts_viewmodel.dart';

class MockGetAllPostsUseCase extends Mock implements GetAllPostsUseCase {}

class MockGetMyPostsUseCase extends Mock implements GetMyPostsUseCase {}

class MockGetPostByIdUsecase extends Mock implements GetPostByIdUsecase {}

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

class MockUpdatePostUseCase extends Mock implements UpdatePostUseCase {}

class MockDeletePostUseCase extends Mock implements DeletePostUseCase {}

class FakeCreatePostParams extends Fake implements CreatePostParams {}

class FakeGetPostByIdParams extends Fake implements GetPostByIdParams {}

void main() {
  late ProviderContainer container;
  late MockGetAllPostsUseCase mockGetAllPostsUseCase;
  late MockGetMyPostsUseCase mockGetMyPostsUseCase;
  late MockGetPostByIdUsecase mockGetPostByIdUseCase;
  late MockCreatePostUseCase mockCreatePostUseCase;
  late MockUpdatePostUseCase mockUpdatePostUseCase;
  late MockDeletePostUseCase mockDeletePostUseCase;

  final testPostEntity = PostEntity(
    id: 'post1',
    title: 'Test Post',
    description: 'Test Description',
    requirements: ['req1', 'req2'],
    tag: 'programming',
    locationType: 'remote',
    availability: 'full-time',
    duration: '1 month',
    userId: 'user1',
    username: 'testuser',
  );

  setUpAll(() {
    registerFallbackValue(FakeCreatePostParams());
    registerFallbackValue(FakeGetPostByIdParams());
    registerFallbackValue('');
  });

  setUp(() {
    mockGetAllPostsUseCase = MockGetAllPostsUseCase();
    mockGetMyPostsUseCase = MockGetMyPostsUseCase();
    mockGetPostByIdUseCase = MockGetPostByIdUsecase();
    mockCreatePostUseCase = MockCreatePostUseCase();
    mockUpdatePostUseCase = MockUpdatePostUseCase();
    mockDeletePostUseCase = MockDeletePostUseCase();

    container = ProviderContainer(
      overrides: [
        getAllPostsUseCaseProvider.overrideWithValue(mockGetAllPostsUseCase),
        getMyPostsUseCaseProvider.overrideWithValue(mockGetMyPostsUseCase),
        getPostByIdUsecaseProvider.overrideWithValue(mockGetPostByIdUseCase),
        createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
        updatePostUseCaseProvider.overrideWithValue(mockUpdatePostUseCase),
        deletePostUseCaseProvider.overrideWithValue(mockDeletePostUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUp(() {
    mockGetAllPostsUseCase = MockGetAllPostsUseCase();
    mockGetMyPostsUseCase = MockGetMyPostsUseCase();
    mockGetPostByIdUseCase = MockGetPostByIdUsecase();
    mockCreatePostUseCase = MockCreatePostUseCase();
    mockUpdatePostUseCase = MockUpdatePostUseCase();
    mockDeletePostUseCase = MockDeletePostUseCase();

    container = ProviderContainer(
      overrides: [
        getAllPostsUseCaseProvider.overrideWithValue(mockGetAllPostsUseCase),
        getMyPostsUseCaseProvider.overrideWithValue(mockGetMyPostsUseCase),
        getPostByIdUsecaseProvider.overrideWithValue(mockGetPostByIdUseCase),
        createPostUseCaseProvider.overrideWithValue(mockCreatePostUseCase),
        updatePostUseCaseProvider.overrideWithValue(mockUpdatePostUseCase),
        deletePostUseCaseProvider.overrideWithValue(mockDeletePostUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PostsViewModel', () {
    group('getMyPosts', () {
      test(
        'sets status to loading then loaded with my posts on success',
        () async {
          when(
            () => mockGetMyPostsUseCase(),
          ).thenAnswer((_) async => Right([testPostEntity]));

          await container.read(postsViewModelProvider.notifier).getMyPosts();

          expect(
            container.read(postsViewModelProvider).status,
            equals(PostStatus.loaded),
          );
          expect(
            container.read(postsViewModelProvider).myPosts,
            equals([testPostEntity]),
          );
          verify(() => mockGetMyPostsUseCase()).called(1);
        },
      );

      test('sets status to error with message on failure', () async {
        when(() => mockGetMyPostsUseCase()).thenAnswer(
          (_) async => Left(ApiFailure(message: 'Failed to load my posts')),
        );

        await container.read(postsViewModelProvider.notifier).getMyPosts();

        expect(
          container.read(postsViewModelProvider).status,
          equals(PostStatus.error),
        );
        expect(
          container.read(postsViewModelProvider).errorMessage,
          equals('Failed to load my posts'),
        );
      });
    });

    group('getPostById', () {
      test(
        'sets status to loading then loaded with selected post on success',
        () async {
          when(
            () => mockGetPostByIdUseCase(any()),
          ).thenAnswer((_) async => Right(testPostEntity));

          await container
              .read(postsViewModelProvider.notifier)
              .getPostById('post1');

          expect(
            container.read(postsViewModelProvider).status,
            equals(PostStatus.loaded),
          );
          expect(
            container.read(postsViewModelProvider).selectedPost,
            equals(testPostEntity),
          );
          verify(() => mockGetPostByIdUseCase(any())).called(1);
        },
      );

      test('sets status to error with message on failure', () async {
        when(() => mockGetPostByIdUseCase(any())).thenAnswer(
          (_) async => Left(ApiFailure(message: 'Failed to load post')),
        );

        await container
            .read(postsViewModelProvider.notifier)
            .getPostById('post1');

        expect(
          container.read(postsViewModelProvider).status,
          equals(PostStatus.error),
        );
        expect(
          container.read(postsViewModelProvider).errorMessage,
          equals('Failed to load post'),
        );
      });
    });

    group('clearError', () {
      test('clears error message', () async {
        when(
          () => mockGetMyPostsUseCase(),
        ).thenAnswer((_) async => Left(ApiFailure(message: 'Some error')));

        await container.read(postsViewModelProvider.notifier).getMyPosts();
        expect(
          container.read(postsViewModelProvider).errorMessage,
          equals('Some error'),
        );

        container.read(postsViewModelProvider.notifier).clearError();
        expect(container.read(postsViewModelProvider).errorMessage, isNull);
      });
    });
  });
}
