import 'package:livefarm_flutter_test/models/PokemonMoveModel.dart';
import 'package:livefarm_flutter_test/services/API/fetchMoves.dart';
import 'package:livefarm_flutter_test/services/database/getMovesDatabase.dart';
import 'package:livefarm_flutter_test/services/database/getPokemonsMovesDatabase.dart';
import 'package:livefarm_flutter_test/services/database/insertMoves.dart';
import 'package:sqflite/sqflite.dart';

Future<List<PokemonMoveModel>> getMoves(int pokemonIndex) async {
  try {
    final Database movesDb = await getMoveDatabase();
    final Database pokemonsMovesDb = await getPokemonsMovesDatabase();
    List<PokemonMoveModel> movesList = [];

    final List<Map<String, dynamic>> movesCurrentPokemon = await pokemonsMovesDb
        .query("pokemons_moves",
            where: "pokemon_id = ?",
            whereArgs: [pokemonIndex],
            columns: ["move_name"]);
    if (movesCurrentPokemon.length >= 1) {
      final List<Map<String, dynamic>> moves = await movesDb.query("moves",
          where:
              "name IN (${movesCurrentPokemon.map((move) => move["move_name"].replaceAll("-", "_")).toList().map((e) => "'$e'").join(", ")})");
      for (dynamic moveJson in moves) {
        movesList.add(PokemonMoveModel.fromJson(moveJson));
      }
      return movesList;
    } else {
      throw Exception("Could not find moves for $pokemonIndex in the database");
    }
  } catch (ex) {
    print(ex);
    final List<PokemonMoveModel> currentMoves = await fetchMoves(pokemonIndex);
    await insertMoves(currentMoves, pokemonIndex);
    return currentMoves;
  }
}
