import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/tags/data/repositories/tags_repository.dart';
import 'package:skillswap/features/tags/domain/entities/tag.dart';
import 'package:skillswap/features/tags/domain/usecases/get_tags.dart';

final getTagsProvider = Provider<GetTags>((ref) {
  final repository = ref.read(tagsRepositoryProvider);
  return GetTags(repository);
});

final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<Tag>>(() {
  return TagsNotifier();
});

class TagsNotifier extends AsyncNotifier<List<Tag>> {
  @override
  Future<List<Tag>> build() async {
    return _fetchTags();
  }

  Future<List<Tag>> _fetchTags() async {
    final getTags = ref.read(getTagsProvider);
    final result = await getTags();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (tags) => tags,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTags());
  }
}
