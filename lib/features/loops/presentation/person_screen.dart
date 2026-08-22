import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../data/providers.dart';
import 'widgets/loop_row.dart';

/// Person view (page spec: design-system/re-mind/pages/person-view.md).
/// T03 delivers the stub: header + open loops. Archived section and counts
/// complete in T11.
class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(loopsRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: repository.getPerson(personId),
          builder: (context, snapshot) {
            final person = snapshot.data;
            if (person == null) {
              return const SizedBox.shrink();
            }
            final initials = person.name
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .map((w) => w[0].toUpperCase())
                .take(2)
                .join();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: BackButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(initials),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              person.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            StreamBuilder(
                              stream:
                                  repository.watchOpenLoopsByPerson(personId),
                              builder: (context, snap) {
                                final count = snap.data?.length ?? 0;
                                return Text(
                                  l10n.personOpenCount(count),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder(
                    stream: repository.watchOpenLoopsByPerson(personId),
                    builder: (context, snap) {
                      final loops = snap.data ?? const [];
                      if (loops.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.personNothingPending(person.name),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 32,
                        ),
                        itemCount: loops.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            LoopRow(item: loops[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
