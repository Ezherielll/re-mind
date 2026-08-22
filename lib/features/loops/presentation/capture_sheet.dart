import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';
import '../../../l10n/app_localizations.dart';
import '../data/providers.dart';
import '../domain/follow_up_schedule.dart';

/// Capture flow (page spec: design-system/re-mind/pages/capture.md).
/// T04 adds the optional due-date row, reminder chips, and the live
/// explainer line. Save computes the plan via [computeSchedule].
enum _Reminder { standard, tomorrow, in3Days, onDue, custom }

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CaptureSheet(),
    );
  }

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final _titleController = TextEditingController();
  final _personController = TextEditingController();
  List<Person> _suggestions = const [];
  Direction _direction = Direction.outgoing;
  DateTime? _dueDate;
  _Reminder _reminder = _Reminder.standard;
  DateTime? _customFollowUp;

  @override
  void dispose() {
    _titleController.dispose();
    _personController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  Future<void> _searchPeople(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (mounted) setState(() => _suggestions = const []);
      return;
    }
    final results = await ref
        .read(loopsRepositoryProvider)
        .searchPeople(trimmed);
    if (mounted) setState(() => _suggestions = results);
  }

  SchedulePlan get _plan {
    final now = DateTime.now();
    return computeSchedule(
      direction: _direction,
      now: now,
      dueDate: _dueDate,
      followUpAt: switch (_reminder) {
        _Reminder.standard => null,
        _Reminder.tomorrow => atReminderHour(now.add(const Duration(days: 1))),
        _Reminder.in3Days => atReminderHour(now.add(const Duration(days: 3))),
        _Reminder.onDue => _dueDate,
        _Reminder.custom => _customFollowUp,
      },
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dueDate = atReminderHour(picked);
      if (_reminder == _Reminder.custom && _customFollowUp == null) {
        _reminder = _Reminder.standard;
      }
    });
  }

  Future<void> _pickCustomReminder() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customFollowUp ?? _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customFollowUp = atReminderHour(picked);
      _reminder = _Reminder.custom;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(loopsRepositoryProvider);

    final personName = _personController.text.trim();
    final personId = personName.isEmpty
        ? null
        : (await repository.findOrCreatePerson(personName)).id;

    final plan = _plan;
    await repository.createCommitment(
      title: title,
      direction: _direction,
      personId: personId,
      dueDate: plan.dueDate,
      followUpAt: plan.followUpAt,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
  }

  String _fmt(DateTime d) => DateFormat('E, d MMM').format(d);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = _canSave ? _plan : null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            autofocus: true,
            controller: _titleController,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.captureHint,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<Direction>(
            segments: [
              ButtonSegment(
                value: Direction.outgoing,
                label: Text(l10n.directionOutgoing),
              ),
              ButtonSegment(
                value: Direction.incoming,
                label: Text(l10n.directionIncoming),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (selection) =>
                setState(() => _direction = selection.first),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _pickDueDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.dueLabel),
                  const Spacer(),
                  Text(
                    _dueDate == null ? l10n.noDueDate : _fmt(_dueDate!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _dueDate == null
                        ? null
                        : () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final choice in _Reminder.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(switch (choice) {
                        _Reminder.standard => l10n.reminderDefault,
                        _Reminder.tomorrow => l10n.reminderTomorrow,
                        _Reminder.in3Days => l10n.reminderIn3Days,
                        _Reminder.onDue => l10n.reminderOnDue,
                        _Reminder.custom => l10n.reminderCustom,
                      }),
                      selected: _reminder == choice,
                      onSelected: (_) async {
                        if (choice == _Reminder.custom) {
                          await _pickCustomReminder();
                          return;
                        }
                        // "On due date" without a due date first opens the
                        // due picker — the chip must never silently no-op.
                        if (choice == _Reminder.onDue && _dueDate == null) {
                          await _pickDueDate();
                          if (!mounted || _dueDate == null) return;
                        }
                        setState(() => _reminder = choice);
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_canSave && plan?.followUpAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.remindExplainer(_fmt(plan!.followUpAt!)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _personController,
            onChanged: _searchPeople,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
              hintText: l10n.capturePersonHint,
            ),
          ),
          if (_suggestions.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final person in _suggestions.take(4))
                    ActionChip(
                      key: ValueKey('suggest-${person.id}'),
                      label: Text(person.name),
                      onPressed: () {
                        _personController.text = person.name;
                        setState(() => _suggestions = const []);
                      },
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
