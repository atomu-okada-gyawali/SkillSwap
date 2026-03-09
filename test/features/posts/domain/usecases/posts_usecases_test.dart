import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skillswap/core/constants/failures.dart';
import 'package:skillswap/features/posts/domain/entities/post_entity.dart';
import 'package:skillswap/features/posts/domain/repositories/posts_repository.dart';
import 'package:skillswap/features/posts/domain/usecases/get_all_posts_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/get_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/update_post_usecase.dart';
import 'package:skillswap/features/posts/domain/usecases/delete_post_usecase.dart';

class MockPostsRepository extends Mock implements IPostsRepository {}

class FakePostEntity extends Fake implements PostEntity {}

void main() {
  late MockPostsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakePostEntity());
  });

  setUp(() {
    mockRepository = MockPostsRepository();
  });

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

  group('GetAllPostsUsecase', () {
    late GetAllPostsUseCase usecase;

    setUp(() {
      usecase = GetAllPostsUseCase(postsRepository: mockRepository);
    });

    test('returns Right(List<PostEntity>) when repository succeeds', () async {
      when(
        () => mockRepository.getAllPosts(any()),
      ).thenAnswer((_) async => Right([testPostEntity]));

      final result = await usecase.call('user1');

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('expected right'),
        (r) => expect(r, equals([testPostEntity])),
      );
      verify(() => mockRepository.getAllPosts('user1')).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(() => mockRepository.getAllPosts(any())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Failed to fetch posts')),
      );

      final result = await usecase.call('user1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });

  group('GetMyPostsUsecase', () {
    late GetMyPostsUseCase usecase;

    setUp(() {
      usecase = GetMyPostsUseCase(postsRepository: mockRepository);
    });

    test('returns Right(List<PostEntity>) when repository succeeds', () async {
      when(
        () => mockRepository.getMyPosts(),
      ).thenAnswer((_) async => Right([testPostEntity]));

      final result = await usecase.call();

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('expected right'),
        (r) => expect(r, equals([testPostEntity])),
      );
      verify(() => mockRepository.getMyPosts()).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(() => mockRepository.getMyPosts()).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Failed to fetch my posts')),
      );

      final result = await usecase.call();

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });

  group('GetPostByIdUsecase', () {
    late GetPostByIdUsecase usecase;

    setUp(() {
      usecase = GetPostByIdUsecase(postsRepository: mockRepository);
    });

    test('returns Right(PostEntity) when repository succeeds', () async {
      when(
        () => mockRepository.getPostById(any()),
      ).thenAnswer((_) async => Right(testPostEntity));

      final result = await usecase.call(
        const GetPostByIdParams(postId: 'post1'),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('expected right'),
        (r) => expect(r, equals(testPostEntity)),
      );
      verify(() => mockRepository.getPostById('post1')).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(
        () => mockRepository.getPostById(any()),
      ).thenAnswer((_) async => Left(ApiFailure(message: 'Post not found')));

      final result = await usecase.call(
        const GetPostByIdParams(postId: 'post1'),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });

  group('CreatePostUsecase', () {
    late CreatePostUseCase usecase;

    setUp(() {
      usecase = CreatePostUseCase(postsRepository: mockRepository);
    });

    test('returns Right(void) when repository succeeds', () async {
      when(
        () => mockRepository.createPost(any(), image: any(named: 'image')),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.call(
        CreatePostParams(
          title: 'New Post',
          description: 'Description',
          requirements: ['req1'],
          locationType: 'remote',
          availability: 'full-time',
        ),
      );

      expect(result.isRight(), isTrue);
      verify(
        () => mockRepository.createPost(any(), image: any(named: 'image')),
      ).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(
        () => mockRepository.createPost(any(), image: any(named: 'image')),
      ).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Failed to create post')),
      );

      final result = await usecase.call(
        CreatePostParams(
          title: 'New Post',
          description: 'Description',
          requirements: ['req1'],
          locationType: 'remote',
          availability: 'full-time',
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });

  group('UpdatePostUsecase', () {
    late UpdatePostUseCase usecase;

    setUp(() {
      usecase = UpdatePostUseCase(postsRepository: mockRepository);
    });

    test('returns Right(void) when repository succeeds', () async {
      when(
        () => mockRepository.updatePost(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.call(
        UpdatePostParams(
          postId: 'post1',
          title: 'Updated Post',
          description: 'Updated Description',
          requirements: ['req1', 'req2'],
          locationType: 'remote',
          availability: 'part-time',
        ),
      );

      expect(result.isRight(), isTrue);
      verify(() => mockRepository.updatePost(any())).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(() => mockRepository.updatePost(any())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Failed to update post')),
      );

      final result = await usecase.call(
        UpdatePostParams(
          postId: 'post1',
          title: 'Updated Post',
          description: 'Updated Description',
          requirements: ['req1', 'req2'],
          locationType: 'remote',
          availability: 'part-time',
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });

  group('DeletePostUsecase', () {
    late DeletePostUseCase usecase;

    setUp(() {
      usecase = DeletePostUseCase(postsRepository: mockRepository);
    });

    test('returns Right(bool) when repository succeeds', () async {
      when(
        () => mockRepository.deletePost(any()),
      ).thenAnswer((_) async => const Right(true));

      final result = await usecase.call('post1');

      expect(result.isRight(), isTrue);
      result.fold((l) => fail('expected right'), (r) => expect(r, isTrue));
      verify(() => mockRepository.deletePost('post1')).called(1);
    });

    test('returns Left(ApiFailure) when repository fails', () async {
      when(() => mockRepository.deletePost(any())).thenAnswer(
        (_) async => Left(ApiFailure(message: 'Failed to delete post')),
      );

      final result = await usecase.call('post1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ApiFailure>()),
        (r) => fail('expected left'),
      );
    });
  });
}
