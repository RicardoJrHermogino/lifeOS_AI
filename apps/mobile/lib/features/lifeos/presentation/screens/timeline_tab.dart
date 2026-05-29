import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_styles.dart';
import 'package:mobile/features/lifeos/data/models/memory_model.dart';
import 'package:mobile/features/lifeos/data/search_repository.dart';
import 'package:mobile/features/lifeos/presentation/providers/search_controller.dart';
import 'package:mobile/features/lifeos/presentation/providers/timeline_controller.dart';
import 'package:mobile/features/lifeos/presentation/screens/memory_review_detail_screen.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:toastification/toastification.dart';

class TimelineTab extends ConsumerStatefulWidget {
  const TimelineTab({super.key});

  @override
  ConsumerState<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends ConsumerState<TimelineTab> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(timelineControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(timelineControllerProvider);
    final filter = ref.watch(timelineFilterControllerProvider);
    final query = ref.watch(searchQueryProvider);
    final searching = query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Icon(
              filter.isEmpty ? Icons.filter_list : Icons.filter_list_alt,
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search memories',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searching
                      ? IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            ref.read(searchQueryProvider.notifier).clear();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).set(value),
              ),
            ),
            if (!filter.isEmpty) _FilterChips(filter: filter),
            Expanded(
              child: searching
                  ? SearchResultsList(query: query)
                  : async.when(
                      data: (state) => _buildList(state, filter),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => _ErrorState(
                        message: '$e',
                        onRetry: () =>
                            ref.invalidate(timelineControllerProvider),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(TimelineState state, TimelineFilter filter) {
    if (state.groups.isEmpty) {
      return _EmptyState(filtered: !filter.isEmpty);
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(timelineControllerProvider),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 124),
        itemCount: state.groups.length + 1,
        itemBuilder: (context, i) {
          if (i == state.groups.length) {
            return _Footer(loading: state.loadingMore, hasMore: state.hasMore);
          }
          final group = state.groups[i];
          final theme = Theme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.s12,
                  bottom: AppSpacing.s12,
                ),
                child: Text(
                  _formatGroupDate(group.date),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              ...group.memories.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: _MemoryCard(memory: m),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final current = ref.read(timelineFilterControllerProvider);
    final result = await showModalBottomSheet<TimelineFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(initial: current),
    );
    if (result != null) {
      ref.read(timelineFilterControllerProvider.notifier).setFilter(result);
    }
  }
}

class SearchResultsList extends ConsumerWidget {
  const SearchResultsList({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchControllerProvider);

    ref.listen(searchControllerProvider, (_, next) {
      if (next.hasError) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text("Couldn't search memories"),
          description: Text('${next.error}'),
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    });

    return async.when(
      data: (hits) {
        if (hits.isEmpty) {
          return _SearchEmptyState(query: query);
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          itemCount: hits.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: _SearchHitCard(hit: hits[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _SearchEmptyState(query: query),
    );
  }
}

class _SearchHitCard extends StatelessWidget {
  const _SearchHitCard({required this.hit});

  final SearchHit hit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MemoryReviewDetailScreen(memory: hit.memory),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hit.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s8),
          Text(
            hit.snippet,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                _formatSearchDate(hit.eventDate),
                style: theme.textTheme.labelSmall,
              ),
              for (final topic in hit.matchedTopics.take(4))
                Chip(label: Text(topic)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.secondaryText(brightness),
            ),
            const SizedBox(height: 16),
            Text(
              'No memories match "$query"',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSearchDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _formatGroupDate(String iso) => iso; // backend returns YYYY-MM-DD

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filter});

  final TimelineFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final entry in filter.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(entry.value),
                onDeleted: () => ref
                    .read(timelineFilterControllerProvider.notifier)
                    .remove(entry.key),
                visualDensity: VisualDensity.compact,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: const Text('Clear all'),
              onPressed: () =>
                  ref.read(timelineFilterControllerProvider.notifier).clear(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MemoryReviewDetailScreen(memory: memory),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(memory.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s8),
          Text(
            memory.summary,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (memory.topics.isNotEmpty || memory.emotions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ...memory.emotions
                    .take(2)
                    .map(
                      (e) => Text(
                        e,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryText(brightness),
                        ),
                      ),
                    ),
                ...memory.topics.take(3).map((t) => Chip(label: Text(t))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) return const SizedBox(height: 24);
    return const SizedBox(height: 48);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 96, 32, 32),
          child: Column(
            children: [
              Icon(
                filtered ? Icons.search_off : Icons.auto_awesome_outlined,
                size: 48,
                color: AppColors.secondaryText(brightness),
              ),
              const SizedBox(height: 16),
              Text(
                filtered ? 'No matching memories' : 'Your timeline is empty',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                filtered
                    ? 'Try clearing or changing your filters.'
                    : 'Capture and save a memory to see it here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(brightness),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text("Couldn't load timeline", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(brightness),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for editing timeline filters. Returns the new filter on apply.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final TimelineFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final TextEditingController _mood = TextEditingController(
    text: widget.initial.mood,
  );
  late final TextEditingController _person = TextEditingController(
    text: widget.initial.person,
  );
  late final TextEditingController _topic = TextEditingController(
    text: widget.initial.topic,
  );
  String? _from;
  String? _to;

  @override
  void initState() {
    super.initState();
    _from = widget.initial.from;
    _to = widget.initial.to;
  }

  @override
  void dispose() {
    _mood.dispose();
    _person.dispose();
    _topic.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    final value =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() {
      if (isFrom) {
        _from = value;
      } else {
        _to = value;
      }
    });
  }

  String? _clean(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  void _apply() {
    Navigator.of(context).pop(
      TimelineFilter(
        mood: _clean(_mood.text),
        person: _clean(_person.text),
        topic: _clean(_topic.text),
        from: _from,
        to: _to,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter timeline', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _mood,
            decoration: const InputDecoration(labelText: 'Mood'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _person,
            decoration: const InputDecoration(labelText: 'Person'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _topic,
            decoration: const InputDecoration(labelText: 'Topic'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isFrom: true),
                  child: Text(_from == null ? 'From date' : 'From $_from'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(isFrom: false),
                  child: Text(_to == null ? 'To date' : 'To $_to'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(const TimelineFilter()),
                  child: const Text('Clear'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: _apply,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
