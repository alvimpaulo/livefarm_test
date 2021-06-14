import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getMoveDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "moves_database.db"),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE moves(name TEXT PRIMARY KEY, id INTEGER, accuracy INTEGER, pp INTEGER, power INTEGER, type INTEGER)',
      );
    },
    version: 1,
  );
}
