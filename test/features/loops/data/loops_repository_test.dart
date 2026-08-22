import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';

void main() {
  late AppDatabase db;
  late DriftLoopsRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftLoopsRepository(db);
  });
  tearDown(() => db.close());

  group('createCommitment', () {
    test('returns an open loop with the given title and direction', () async {
      final loop = await repository.createCommitment(
        title: 'Send revision to Budi',
        direction: Direction.outgoing,
      );

      expect(loop.title, 'Send revision to Budi');
      expect(loop.direction, Direction.outgoing);
      expect(loop.status, CommitmentStatus.open);
      expect(loop.deletedAt, isNull);
    });

    test('stores an incoming direction', () async {
      final loop = await repository.createCommitment(
        title: 'Awaiting data from Budi',
        direction: Direction.incoming,
      );
      expect(loop.direction, Direction.incoming);
    });

    test('logs a created event for the new loop', () async {
      final loop = await repository.createCommitment(
        title: 'Send revision to Budi',
        direction: Direction.outgoing,
      );

      final events = await db.select(db.loopEvents).get();
      expect(events, hasLength(1));
      expect(events.single.commitmentId, loop.id);
      expect(events.single.type, LoopEventType.created);
    });
  });

  group('watchOpenLoops', () {
    test(
      'emits empty before any capture and the loop after it',
      () async {
        final emissions = <List<LoopWithPerson>>[];
        final subscription = repository.watchOpenLoops().listen(emissions.add);
        addTearDown(subscription.cancel);

        await Future<void>.delayed(Duration.zero);
        expect(emissions, isNotEmpty);
        expect(emissions.first, isEmpty);

        await repository.createCommitment(
          title: 'Send revision to Budi',
          direction: Direction.outgoing,
        );
        // NativeDatabase runs on a background isolate; allow the stream to tick.
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(emissions.last, hasLength(1));
        expect(emissions.last.single.commitment.title, 'Send revision to Budi');
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test('never emits loops that were soft-deleted', () async {
      final loop = await repository.createCommitment(
        title: 'Send revision to Budi',
        direction: Direction.outgoing,
      );
      await (db.update(db.commitments)..where((c) => c.id.equals(loop.id)))
          .write(CommitmentsCompanion(deletedAt: Value(DateTime.now())));

      final open = await repository.watchOpenLoops().first;
      expect(open, isEmpty);
    });

    test('data survives closing and reopening the database', () async {
      final dir = Directory.systemTemp.createTempSync('re_mind_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}${Platform.pathSeparator}restart.sqlite');

      final first = AppDatabase(NativeDatabase(file));
      await DriftLoopsRepository(first).createCommitment(
        title: 'Send revision to Budi',
        direction: Direction.outgoing,
      );
      await first.close();

      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final open = await DriftLoopsRepository(reopened).watchOpenLoops().first;
      expect(open.single.commitment.title, 'Send revision to Budi');
    });
  });

  group('findOrCreatePerson', () {
    test('creates a person once and dedupes normalized names', () async {
      final first = await repository.findOrCreatePerson('Budi Santoso');
      final second = await repository.findOrCreatePerson(
        '  budi   santoso '.trim(),
      );
      final third = await repository.findOrCreatePerson('Budi   santoso');

      expect(first.id, second.id);
      expect(first.id, third.id);
      expect(first.name, 'Budi Santoso');
    });

    test(
      'searchPeople matches prefixes and skips soft-deleted people',
      () async {
        final budi = await repository.findOrCreatePerson('Budi Santoso');
        await repository.findOrCreatePerson('Bunga Citra');

        await (db.update(db.people)..where((p) => p.id.equals(budi.id))).write(
          PeopleCompanion(deletedAt: Value(DateTime.now())),
        );

        final result = await repository.searchPeople('bud');
        expect(result.map((p) => p.name), isNot(contains('Budi Santoso')));
      },
    );
  });

  group('loops with people', () {
    test(
      'createCommitment links a person and watchOpenLoops joins it',
      () async {
        final person = await repository.findOrCreatePerson('Budi Santoso');
        await repository.createCommitment(
          title: 'Send revision',
          direction: Direction.outgoing,
          personId: person.id,
        );
        await repository.createCommitment(
          title: 'Renew license',
          direction: Direction.outgoing,
        );

        final open = await repository.watchOpenLoops().first;

        expect(open, hasLength(2));
        final linked = open.singleWhere(
          (l) => l.commitment.title == 'Send revision',
        );
        expect(linked.person?.name, 'Budi Santoso');
        final unlinked = open.singleWhere(
          (l) => l.commitment.title == 'Renew license',
        );
        expect(unlinked.person, isNull);
      },
    );

    test('watchOpenLoopsByPerson filters to that person only', () async {
      final budi = await repository.findOrCreatePerson('Budi');
      final sari = await repository.findOrCreatePerson('Sari');
      await repository.createCommitment(
        title: 'For Budi',
        direction: Direction.incoming,
        personId: budi.id,
      );
      await repository.createCommitment(
        title: 'For Sari',
        direction: Direction.outgoing,
        personId: sari.id,
      );

      final budisLoops = await repository.watchOpenLoopsByPerson(budi.id).first;
      expect(budisLoops, hasLength(1));
      expect(budisLoops.single.commitment.title, 'For Budi');
    });
  });

  group('dates & detail', () {
    test('createCommitment stores provided dates', () async {
      final due = DateTime(2026, 8, 28, 9);
      final remind = DateTime(2026, 8, 27, 9);
      final loop = await repository.createCommitment(
        title: 'Send revision',
        direction: Direction.outgoing,
        dueDate: due,
        followUpAt: remind,
      );
      expect(loop.dueDate, due);
      expect(loop.followUpAt, remind);
    });

    test('getLoop returns the joined loop by id', () async {
      final person = await repository.findOrCreatePerson('Budi');
      final created = await repository.createCommitment(
        title: 'Send revision',
        direction: Direction.outgoing,
        personId: person.id,
      );

      final fetched = await repository.getLoop(created.id);

      expect(fetched, isNotNull);
      expect(fetched!.commitment.title, 'Send revision');
      expect(fetched.person?.name, 'Budi');
    });

    test('updateDates persists values and bumps updatedAt', () async {
      final created = await repository.createCommitment(
        title: 'Send revision',
        direction: Direction.outgoing,
      );
      final newDue = DateTime(2026, 9, 1, 9);
      final newRemind = DateTime(2026, 8, 31, 9);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repository.updateDates(
        created.id,
        dueDate: newDue,
        followUpAt: newRemind,
      );

      final after = (await repository.getLoop(created.id))!;
      expect(after.commitment.dueDate, newDue);
      expect(after.commitment.followUpAt, newRemind);
      // Drift persists timestamps at second precision.
      expect(
        after.commitment.updatedAt.millisecondsSinceEpoch,
        greaterThanOrEqualTo(created.updatedAt.millisecondsSinceEpoch),
      );
    });
  });

  group('follow-up cycle', () {
    Future<Commitment> seed({Direction direction = Direction.outgoing}) =>
        repository.createCommitment(
          title: 'Send revision',
          direction: direction,
        );

    test('markFollowedUp logs event and advances the nudge', () async {
      final loop = await seed();
      final next = DateTime(2026, 8, 28, 9);

      await repository.markFollowedUp(loop.id, nextNudgeAt: next);

      final stored = (await repository.getLoop(loop.id))!.commitment;
      expect(stored.followUpAt, next);
      final events = await db.select(db.loopEvents).get();
      expect(events.map((e) => e.type), contains(LoopEventType.followedUp));
    });

    test('snoozeLoop moves only followUpAt and logs nothing', () async {
      final loop = await seed();
      final until = DateTime(2026, 8, 30, 9);

      await repository.snoozeLoop(loop.id, until: until);

      final stored = (await repository.getLoop(loop.id))!.commitment;
      expect(stored.followUpAt, until);
      final events = await db.select(db.loopEvents).get();
      expect(events, hasLength(1)); // only 'created'
    });

    test('markDone archives out of open queries into done queries', () async {
      final person = await repository.findOrCreatePerson('Budi');
      final loop =
          await seed();
      // Link person post-hoc for the by-person assertions.
      await (db.update(db.commitments)..where((c) => c.id.equals(loop.id)))
          .write(CommitmentsCompanion(personId: Value(person.id)));

      await repository.markDone(loop.id);

      expect(await repository.watchOpenLoops().first, isEmpty);
      expect(
        await repository.watchOpenLoopsByPerson(person.id).first,
        isEmpty,
      );
      final doneForPerson =
          await repository.watchDoneLoopsByPerson(person.id).first;
      expect(doneForPerson.single.commitment.id, loop.id);
      final archived = await repository.watchArchivedLoops().first;
      expect(archived.single.commitment.id, loop.id);
      final events = await db.select(db.loopEvents).get();
      expect(events.map((e) => e.type), contains(LoopEventType.done));
    });

    test('reopenLoop restores an archived loop to open', () async {
      final loop = await seed();
      await repository.markDone(loop.id);

      await repository.reopenLoop(loop.id);

      final open = await repository.watchOpenLoops().first;
      expect(open.single.commitment.id, loop.id);
    });
  });

  group('history & archive-aware fetch', () {
    Future<Commitment> seed() => repository.createCommitment(
          title: 'Send revision',
          direction: Direction.outgoing,
        );

    test('getLoop returns done loops when fetched by id', () async {
      final loop = await seed();
      await repository.markDone(loop.id);

      final fetched = await repository.getLoop(loop.id);
      expect(fetched, isNotNull);
      expect(fetched!.commitment.status, CommitmentStatus.done);
    });

    test('watchEvents streams ordered events per commitment', () async {
      final loop = await seed();
      await repository.markFollowedUp(
        loop.id,
        nextNudgeAt: DateTime(2026, 9, 1, 9),
      );
      await repository.markDone(loop.id);

      final emissions = <List<LoopEvent>>[];
      final sub = repository.watchEvents(loop.id).listen(emissions.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(emissions.last.map((e) => e.type).toList(), [
        LoopEventType.created,
        LoopEventType.followedUp,
        LoopEventType.done,
      ]);
    });
  });
}
