import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/services/API/fetchPokemon.dart';
import 'package:livefarm_flutter_test/services/database/getPokemonDatabase.dart';
import 'package:livefarm_flutter_test/services/database/insertPokemon.dart';
import 'package:sqflite/sqflite.dart';

Future<PokemonModel> getPokemon(int pokemonIndex) async {
  try {
    final Database db = await getPokemonDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query("pokemons", where: "id = ?", whereArgs: [pokemonIndex]);
    if (maps.length >= 1)
      return PokemonModel.fromMap(maps[0]);
    else
      throw Exception("Could not find $pokemonIndex in the database");
  } catch (err) {
    if (err.toString() !=
        "Exception: Could not find $pokemonIndex in the database") {
      print(err);
    }
    final PokemonModel currentPoke = await fetchPokemon(pokemonIndex);
    if (currentPoke.id != -1) {
      await insertPokemon(currentPoke);
      return currentPoke;
    } else {
      return currentPoke;
    }
  }
}
