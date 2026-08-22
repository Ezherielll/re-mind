import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';
import '../../../core/domain/digest.dart';
import '../../../core/domain/derived_status.dart';
import '../../../l10n/app_localizations.dart';
import '../data/providers.dart';
import '../../settings/presentation/settings_screen.dart';
import '../data/reminder_coordinator.dart';
import 'capture_sheet.dart';
import 'home_groups.dart';
import 'loop_detail_screen.dart';
import 'person_screen.dart';
import 'search_screen.dart';
import 'widgets/loop_row.dart';

/// Sample loops still present (T09 banner).
final samplesProvider = FutureProvider<List<Commitment>>(
  (ref) => ref.watch(loopsRepositoryProvider).sampleLoops(),
);

/// Active direction filter on the home list (null = All).
class DirectionFilter extends Notifier<Direction?> {
  @override
  Direction? build() => null;

  void set(Direction? direction) => state = direction;
}

final directionFilterProvider = NotifierProvider<DirectionFilter, Direction?>(
  DirectionFilter.new,
);

/// Home screen: the single prioritized open-loop list (page spec:
/// design-system/re-mind/pages/home.md). Grouped by derived status via
/// [groupOpenLoops]; filter chips narrow by Direction.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loops = ref.watch(openLoopsProvider);
    // Keep scheduled item alerts + digest fresh with live data (T07/T08).
    ref.listen(openLoopsProvider, (_, next) {
      final items = next.value;
      if (items == null) return;
      final now = DateTime.now();
      final dueTodayCount = items
          .where((l) => isDueToday(l.commitment.dueDate, now))
          .length;
      unawaited(
        ref.read(reminderCoordinatorProvider).sync(
              items,
              now: now,
              dueTodayTitle: (t) => '${l10n.statusDue}: $t',
              digestTime: ref.watch(digestTimeProvider).value,
              digestBody: composeDigestBody(
                totalOpen: items.length,
                dueToday: dueTodayCount,
                noneTemplate: l10n.digestNone,
                hangingTemplate: (Object c) => l10n.digestHanging(c),
                chaseTemplate: (Object c) => l10n.digestChase(c),
              ),
            ),
      );
    });
    final totalOpen = loops.value?.length ?? 0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    l10n.homeTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                    ),
                  ),
                  if (totalOpen > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$totalOpen',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.searchHint,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const SearchScreen()),
                    ),
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    tooltip: l10n.settingsTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _FilterChips(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(totalOpen),
                    child: loops.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => Center(
                        child: Text(
                          l10n.homeError,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      data: (items) {
                        final groups = groupOpenLoops(
                          items,
                          directionFilter: ref.watch(directionFilterProvider),
                          now: DateTime.now(),
                        );
                        if (groups.isEmpty) {
                          return const _EmptyState();
                        }
                        return _GroupedList(
                      groups,
                      sampleIds: ref.watch(samplesProvider).value
                              ?.map((c) => c.id)
                              .toSet() ??
                          const <int>{},
                      onRemoveSamples: () async {
                        await ref
                            .read(loopsRepositoryProvider)
                            .removeAllSamples();
                        ref.invalidate(samplesProvider);
                        ref.invalidate(openLoopsProvider);
                      },
                    );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CaptureSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.homeCaptureLabel),
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(directionFilterProvider);
    return Row(
      children: [
        _chip(
          context,
          label: l10n.filterAll,
          selected: selected == null,
          onSelected: () =>
              ref.read(directionFilterProvider.notifier).set(null),
        ),
        const SizedBox(width: 8),
        _chip(
          context,
          label: l10n.directionOutgoing,
          selected: selected == Direction.outgoing,
          onSelected: () => ref
              .read(directionFilterProvider.notifier)
              .set(Direction.outgoing),
        ),
        const SizedBox(width: 8),
        _chip(
          context,
          label: l10n.directionIncoming,
          selected: selected == Direction.incoming,
          onSelected: () => ref
              .read(directionFilterProvider.notifier)
              .set(Direction.incoming),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final display = Theme.of(context).textTheme.headlineMedium;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('0', style: display?.copyWith(fontSize: 64)),
          const SizedBox(height: 8),
          Text(
            l10n.homeEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () {}, child: Text(l10n.homeEmptyCta)),
        ],
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList(
    this.groups, {
    required this.sampleIds,
    required this.onRemoveSamples,
  });

  final List<LoopGroup> groups;
  final Set<int> sampleIds;
  final Future<void> Function() onRemoveSamples;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (sampleIds.isNotEmpty) {
      children.add(_SampleBanner(onRemove: onRemoveSamples));
    }
    for (final group in groups) {
      children.add(
        _GroupHeader(status: group.status, count: group.loops.length),
      );
      for (final item in group.loops) {
        children.add(
          LoopRow(
            item: item,
            status: group.status,
            isSample: sampleIds.contains(item.commitment.id),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LoopDetailScreen(loopId: item.commitment.id),
              ),
            ),
            onTapPerson: item.person == null
                ? null
                : (person) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PersonScreen(personId: person.id),
                    ),
                  ),
          ),
        );
        children.add(const Divider(height: 1));
      }
      children.add(const SizedBox(height: 16));
    }
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 96),
      children: children,
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.status, required this.count});

  final DerivedStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (status) {
      DerivedStatus.followUpDue => l10n.statusFollowUpDue,
      DerivedStatus.due => l10n.statusDue,
      DerivedStatus.upcoming => l10n.statusUpcoming,
      DerivedStatus.onTrack => l10n.statusOnTrack,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              color: statusColor(context, status),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.groupCount(count),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleBanner extends StatelessWidget {
  const _SampleBanner({required this.onRemove});

  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(l10n.samplesBanner, style: Theme.of(context).textTheme.bodySmall)),
          TextButton(onPressed: onRemove, child: Text(l10n.removeSamples)),
        ],
      ),
    );
  }
}