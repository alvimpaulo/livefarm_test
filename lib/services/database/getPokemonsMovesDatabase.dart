import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getPokemonsMovesDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "pokemons_moves_database.db"),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE pokemons_moves(id INTEGER PRIMARY KEY AUTOINCREMENT, pokemon_id INTEGER NOT NULL, move_name TEXT NOT NULL, FOREIGN KEY (pokemon_id) references pokemons (id) ON DELETE NO ACTION ON UPDATE NO ACTION, FOREIGN KEY (move_name) references moves (name) ON DELETE NO ACTION ON UPDATE NO ACTION)',
      );
    },
    version: 1,
  );
}
