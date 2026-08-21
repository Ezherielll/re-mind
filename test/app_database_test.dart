import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';

void main() {
  // Constructing AppDatabase must not open the database (LazyDatabase only
  // resolves on first query), so this is safe without a native sqlite3 lib.
  test('schema starts at version 1', () {
    final db = AppDatabase();
    addTearDown(() {
      // Never opened; closing a lazy database that was never opened is a no-op.
      db.close();
    });
    expect(db.schemaVersion, 1);
  });
}
