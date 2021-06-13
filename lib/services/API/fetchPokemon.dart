import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:livefarm_flutter_test/models/PokemonModel.dart';

Future<PokemonModel> fetchPokemon(int pokemonIndex) async {
  final response = await http
      .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/$pokemonIndex"));
  if (response.statusCode == 200) {
    final dynamic pokemonJson = jsonDecode(response.body);

    return PokemonModel.fromJson(pokemonJson);
  } else {
    throw Exception("Falha em retornar o pokemon $pokemonIndex");
  }
}
