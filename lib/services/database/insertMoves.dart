import 'package:livefarm_flutter_test/models/PokemonMoveModel.dart';
import 'package:livefarm_flutter_test/services/database/getMovesDatabase.dart';
import 'package:livefarm_flutter_test/services/database/getPokemonsMovesDatabase.dart';
import 'package:sqflite/sqflite.dart';

Future<void> insertMoves(List<PokemonMoveModel> moves, int pokemonIndex) async {
  try {
    final Database moveDb = await getMoveDatabase();
    final Database pokemonsMovesDb = await getPokemonsMovesDatabase();

    for (PokemonMoveModel move in moves) {
      await moveDb.insert(
        "moves",
        move.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await pokemonsMovesDb.insert(
        "pokemons_moves",
        {"pokemon_id": pokemonIndex, "move_name": move.name},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  } catch (ex) {
    print("Error inserting moves");
    print(ex);
    return;
  }
}
