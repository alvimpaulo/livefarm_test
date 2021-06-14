import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:livefarm_flutter_test/models/PokemonModel.dart';

Future<PokemonModel> fetchPokemon(int pokemonIndex) async {
  try {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/$pokemonIndex"));
    if (response.statusCode == 200) {
      final dynamic pokemonJson = jsonDecode(response.body);

      return PokemonModel.fromJson(pokemonJson);
    } else {
      throw HttpException(
          "Status code ${response.statusCode} when fetching pokemon $pokemonIndex");
    }
  } catch (e) {
    print(e);
    print("Error fetching pokemon");
    return PokemonModel(
        id: -1,
        name: "none",
        frontPixelArt: "none",
        frontHighQuality: "none",
        weight: -1,
        stats: [],
        abilities: []);
  }
}
