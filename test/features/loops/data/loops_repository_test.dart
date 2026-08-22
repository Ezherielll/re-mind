import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/domain/commitment.dart';

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
    test('emits empty before any capture and the loop after it', () async {
      final emissions = <List<Commitment>>[];
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
      expect(emissions.last.single.title, 'Send revision to Budi');
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('never emits loops that were soft-deleted', () async {
      final loop = await repository.createCommitment(
        title: 'Send revision to Budi',
        direction: Direction.outgoing,
      );
      await (db.update(db.commitments)
            ..where((c) => c.id.equals(loop.id)))
          .write(CommitmentsCompanion(deletedAt: Value(DateTime.now())));

      final open = await repository.watchOpenLoops().first;
      expect(open, isEmpty);
    });  });
}
