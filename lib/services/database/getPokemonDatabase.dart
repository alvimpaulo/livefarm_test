import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getPokemonDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "pokemons_database.db"),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE pokemons(id INTEGER PRIMARY KEY, name TEXT, img_pixel_art TEXT, img_high_quality TEXT, weight INTEGER, stats TEXT, abilities TEXT)',
      );
    },
    version: 1,
  );
}
