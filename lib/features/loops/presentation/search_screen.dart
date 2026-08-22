import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/derived_status.dart';
import '../../../l10n/app_localizations.dart';
import '../data/loops_repository.dart';
import '../data/providers.dart';
import 'loop_detail_screen.dart';
import 'person_screen.dart';
import 'widgets/loop_row.dart';

/// Live search over commitments and people (pages/home.md → search page).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  Future<(List<Person>, List<LoopWithPerson>)>? _results;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _results = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 200), () {
      final repo = ref.read(loopsRepositoryProvider);
      Future<(List<Person>, List<LoopWithPerson>)> run() async => (
            await repo.searchPeople(q, limit: 5),
            await repo.searchLoops(q),
          );
      setState(() => _results = run());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  BackButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: _controller,
                      onChanged: _onChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        hintText: l10n.searchHint,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: _results == null
                    ? Center(
                        child: Text(
                          l10n.searchHint,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      )
                    : FutureBuilder<(List<Person>, List<LoopWithPerson>)>(
                        future: _results,
                        builder: (context, snap) {
                          final people =
                              snap.data?.$1 ?? const <Person>[];
                          final loops =
                              snap.data?.$2 ?? const <LoopWithPerson>[];
                          if (people.isEmpty && loops.isEmpty) {
                            return Center(child: Text(l10n.noMatches));
                          }
                          return ListView(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 32),
                            children: [
                              for (final p in people)
                                ListTile(
                                  key: ValueKey('p-${p.id}'),
                                  leading: CircleAvatar(
                                    radius: 16,
                                    child:
                                        Text(p.name[0].toUpperCase()),
                                  ),
                                  title: Text(p.name),
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => PersonScreen(
                                        personId: p.id,
                                      ),
                                    ),
                                  ),
                                ),
                              if (people.isNotEmpty && loops.isNotEmpty)
                                _label(l10n.searchLoopsLabel),
                              if (people.isNotEmpty && loops.isNotEmpty)
                                const SizedBox(height: 4),
                              for (final item in loops)
                                LoopRow(
                                  item: item,
                                  status: deriveStatus(
                                    now: DateTime.now(),
                                    followUpAt:
                                        item.commitment.followUpAt,
                                    dueDate: item.commitment.dueDate,
                                  ),
                                  onTap: () =>
                                      Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => LoopDetailScreen(
                                        loopId: item.commitment.id,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 2),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.05,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
}
