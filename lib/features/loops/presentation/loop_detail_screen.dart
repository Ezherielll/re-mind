import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';
import '../../../l10n/app_localizations.dart';
import '../data/loops_repository.dart';
import '../data/providers.dart';
import '../domain/follow_up_schedule.dart';
import 'person_screen.dart';

/// Loop detail (page spec: design-system/re-mind/pages/loop-detail.md).
/// T06 adds the pinned action bar (Followed up / Snooze / Done) with the
/// snooze-cycle rule. Notes arrive with T10, history with T11.
class LoopDetailScreen extends ConsumerStatefulWidget {
  const LoopDetailScreen({super.key, required this.loopId});

  final int loopId;

  @override
  ConsumerState<LoopDetailScreen> createState() => _LoopDetailScreenState();
}

class _LoopDetailScreenState extends ConsumerState<LoopDetailScreen> {
  LoopWithPerson? _loop;
  TextEditingController? _noteController;
  Timer? _noteDebounce;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _noteDebounce?.cancel();
    _noteController?.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final loop = await ref.read(loopsRepositoryProvider).getLoop(widget.loopId);
    if (mounted) {
      setState(() {
        _loop = loop;
        if (_noteController == null && loop != null) {
          _noteController = TextEditingController(text: loop.commitment.note);
        }
      });
    }
  }

  void _onNoteChanged(String value) {
    _noteDebounce?.cancel();
    _noteDebounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(loopsRepositoryProvider).updateNote(widget.loopId, value);
    });
  }

  Future<void> _pickDate({required bool isDue}) async {
    final l10n = AppLocalizations.of(context);
    final loop = _loop;
    if (loop == null) return;
    final current = isDue
        ? loop.commitment.dueDate
        : loop.commitment.followUpAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    final atNine = DateTime(picked.year, picked.month, picked.day, 9);
    await ref
        .read(loopsRepositoryProvider)
        .updateDates(
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

  Future<void> _onFollowedUp() async {
    final l10n = AppLocalizations.of(context);
    final loop = _loop;
    if (loop == null) return;
    final next = nextFollowUpAfter(
      now: DateTime.now(),
      currentFollowUpAt: loop.commitment.followUpAt,
      dueDate: loop.commitment.dueDate,
    );
    await ref.read(loopsRepositoryProvider).markFollowedUp(
          widget.loopId,
          nextNudgeAt: next,
        );
    await _reload();
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(l10n.reminderMoved(_fmt(next))),
        ));
    }
  }

  Future<void> _onSnooze(int days) async {
    await ref
        .read(loopsRepositoryProvider)
        .snoozeLoop(widget.loopId, until: snoozeUntil(now: DateTime.now(), days: days));
    await _reload();
  }

  Future<void> _onDone() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final repository = ref.read(loopsRepositoryProvider);
    await repository.markDone(widget.loopId);
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.archivedToast),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () => repository.reopenLoop(widget.loopId),
      ),
    ));
  }

  void _showSnoozeSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.snooze1Day),
              onTap: () {
                Navigator.pop(sheetContext);
                _onSnooze(1);
              },
            ),
            ListTile(
              title: Text(l10n.snooze3Days),
              onTap: () {
                Navigator.pop(sheetContext);
                _onSnooze(3);
              },
            ),
            ListTile(
              title: Text(l10n.reminderCustom),
              onTap: () async {
                Navigator.pop(sheetContext);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked == null || !mounted) return;
                final now = DateTime.now();
                final todayStart = DateTime(now.year, now.month, now.day);
                final days =
                    picked.difference(todayStart).inDays.clamp(1, 730);
                await _onSnooze(days);
              },
            ),
          ],
        ),
      ),
    );
  }

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
                              loop.commitment.direction == Direction.outgoing
                                  ? Icons.north_east
                                  : Icons.south_west,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loop.commitment.title,
                                style: Theme.of(context).textTheme.titleLarge
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
                                            followUpAt:
                                                loop.commitment.followUpAt,
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
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        PersonScreen(personId: loop.person!.id),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.notesLabel.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.05,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _noteController,
                          onChanged: _onNoteChanged,
                          minLines: 2,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: l10n.noteHint,
                          ),
                        ),                        const SizedBox(height: 16),
                        Text(
                          l10n.historyLabel.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.05,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<List<LoopEvent>>(
                          stream: ref
                              .read(loopsRepositoryProvider)
                              .watchEvents(widget.loopId),
                          builder: (context, snap) {
                            final events = snap.data ?? const <LoopEvent>[];
                            if (events.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                for (final e in events)
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(switch (e.type) {
                                      LoopEventType.created =>
                                        Icons.add_circle_outline,
                                      LoopEventType.followedUp =>
                                        Icons.send_outlined,
                                      LoopEventType.done =>
                                        Icons.check_circle_outline,
                                    }),
                                    title: Text(switch (e.type) {
                                      LoopEventType.created => 'Created',
                                      LoopEventType.followedUp =>
                                        'Followed up',
                                      LoopEventType.done => 'Done',
                                    }),
                                    trailing: Text(
                                      DateFormat('d MMM, HH:mm')
                                          .format(e.occurredAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _ActionBar(
                    isArchived: loop.commitment.status == CommitmentStatus.done,
                    onFollowedUp: _onFollowedUp,
                    onSnooze: _showSnoozeSheet,
                    onDone: _onDone,
                    onReopen: () async {
                      await ref
                          .read(loopsRepositoryProvider)
                          .reopenLoop(widget.loopId);
                      await _reload();
                    },
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

/// Pinned action bar (pages/loop-detail.md): Followed up / Snooze / Done.
/// Archived loops show a single Reopen button instead.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isArchived,
    required this.onFollowedUp,
    required this.onSnooze,
    required this.onDone,
    required this.onReopen,
  });

  final bool isArchived;
  final Future<void> Function() onFollowedUp;
  final VoidCallback onSnooze;
  final Future<void> Function() onDone;
  final Future<void> Function() onReopen;

  @override
  Widget build(BuildContext context) {
    if (isArchived) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onReopen,
            child: Text(AppLocalizations.of(context).reopen),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonal(
              onPressed: onFollowedUp,
              child: Text(AppLocalizations.of(context).followedUpLabel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: onSnooze,
              child: Text(AppLocalizations.of(context).snoozeLabel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onDone,
              child: Text(AppLocalizations.of(context).doneLabel),
            ),
          ),
        ],
      ),
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
