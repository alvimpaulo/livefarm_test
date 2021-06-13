// Define a function that inserts pokemons into the database
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/services/database/getPokemonDatabase.dart';
import 'package:sqflite/sqflite.dart';

Future<void> insertPokemon(PokemonModel pokemon) async {
  try {
    final Database pokemonDb = await getPokemonDatabase();

    await pokemonDb.insert(
      "pokemons",
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (ex) {
    print("Error inserting pokemon");
    print(ex);
    return;
  }
}
