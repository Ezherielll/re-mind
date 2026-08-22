import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/domain/commitment.dart';
import '../../../l10n/app_localizations.dart';
import '../data/loops_repository.dart';
import '../data/providers.dart';
import 'person_screen.dart';

/// Loop detail (page spec: design-system/re-mind/pages/loop-detail.md).
/// T04 scope: header + meta card with editable dates and person row.
/// Notes arrive with T10, history with T11, action bar with T06.
class LoopDetailScreen extends ConsumerStatefulWidget {
  const LoopDetailScreen({super.key, required this.loopId});

  final int loopId;

  @override
  ConsumerState<LoopDetailScreen> createState() => _LoopDetailScreenState();
}

class _LoopDetailScreenState extends ConsumerState<LoopDetailScreen> {
  LoopWithPerson? _loop;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final loop = await ref.read(loopsRepositoryProvider).getLoop(widget.loopId);
    if (mounted) setState(() => _loop = loop);
  }

  Future<void> _pickDate({required bool isDue}) async {
    final l10n = AppLocalizations.of(context);
    final loop = _loop;
    if (loop == null) return;
    final current = isDue ? loop.commitment.dueDate : loop.commitment.followUpAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    final atNine = DateTime(picked.year, picked.month, picked.day, 9);
    await ref.read(loopsRepositoryProvider).updateDates(
          widget.loopId,
          dueDate: isDue ? atNine : loop.commitment.dueDate,
          followUpAt: isDue ? loop.commitment.followUpAt : atNine,
        );
    await _reload();
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.saved)));
    }
  }

  String _fmt(DateTime d) => DateFormat('E, d MMM').format(d);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loop = _loop;
    return Scaffold(
      body: SafeArea(
        child: loop == null
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: BackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Row(
                          children: [
                            Icon(
                              loop.commitment.direction ==
                                      Direction.outgoing
                                  ? Icons.north_east
                                  : Icons.south_west,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loop.commitment.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _MetaCard(
                          children: [
                            _MetaRow(
                              icon: Icons.event_outlined,
                              label: l10n.dueLabel,
                              value: loop.commitment.dueDate == null
                                  ? l10n.noDueDate
                                  : _fmt(loop.commitment.dueDate!),
                              onTap: () => _pickDate(isDue: true),
                              onClear: loop.commitment.dueDate == null
                                  ? null
                                  : () async {
                                      await ref
                                          .read(loopsRepositoryProvider)
                                          .updateDates(
                                            widget.loopId,
                                            dueDate: null,
                                            followUpAt: loop
                                                .commitment.followUpAt,
                                          );
                                      await _reload();
                                    },
                            ),
                            _divider(),
                            _MetaRow(
                              icon: Icons.notifications_none,
                              label: l10n.remindsLabel,
                              value: loop.commitment.followUpAt == null
                                  ? l10n.noneLabel
                                  : _fmt(loop.commitment.followUpAt!),
                              onTap: () => _pickDate(isDue: false),
                            ),
                            if (loop.person != null) ...[
                              _divider(),
                              _MetaRow(
                                icon: Icons.person_outline,
                                label: loop.person!.name,
                                value: '',
                                onTap: () =>
                                    Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PersonScreen(
                                      personId: loop.person!.id,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            if (value.isNotEmpty)
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            if (onClear != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
