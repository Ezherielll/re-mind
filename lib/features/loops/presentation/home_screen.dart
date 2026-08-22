import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/loops_repository.dart';
import '../data/providers.dart';
import 'capture_sheet.dart';
import 'person_screen.dart';
import 'widgets/loop_row.dart';

/// Home screen: the single prioritized open-loop list (page spec:
/// design-system/re-mind/pages/home.md). Grouping by derived status arrives
/// with T05; rows are flat until then.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loops = ref.watch(openLoopsProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.homeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                    ),
              ),
              Expanded(
                child: loops.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => Center(
                    child: Text(
                      l10n.homeError,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  data: (items) => items.isEmpty
                      ? const _EmptyState()
                      : _LoopList(items),
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

class _LoopList extends StatelessWidget {
  const _LoopList(this.items);

  final List<LoopWithPerson> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return LoopRow(
          item: item,
          onTapPerson: item.person == null
              ? null
              : (person) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PersonScreen(personId: person.id),
                    ),
                  ),
        );
      },
    );
  }
}
