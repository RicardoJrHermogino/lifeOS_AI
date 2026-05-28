import 'package:mobile/features/lifeos/data/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_controller.g.dart';

@Riverpod(keepAlive: true)
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

@Riverpod(keepAlive: true)
class SearchController extends _$SearchController {
  static const debounceDuration = Duration(milliseconds: 300);

  @override
  Future<List<SearchHit>> build() async {
    final query = ref.watch(searchQueryProvider).trim();
    if (query.isEmpty) return [];

    await Future<void>.delayed(debounceDuration);
    if (!ref.mounted) return [];
    if (query != ref.read(searchQueryProvider).trim()) return [];

    return ref.read(searchRepositoryProvider).search(query);
  }
}
