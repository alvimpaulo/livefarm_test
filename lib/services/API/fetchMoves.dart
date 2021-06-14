import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:livefarm_flutter_test/models/PokemonMoveModel.dart';

Future<List<PokemonMoveModel>> fetchMoves(int pokemonIndex) async {
  try {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/$pokemonIndex"));
    if (response.statusCode == 200) {
      final dynamic pokemonJson = jsonDecode(response.body);

      final List<dynamic> movesJson = pokemonJson["moves"];
      final List<PokemonMoveModel> pokeMoves = [];

      for (dynamic move in movesJson) {
        final String name = move["move"]["name"];
        final String url = move["move"]["url"];
        try {
          final moveResponse = await http.get(Uri.parse(url));
          if (moveResponse.statusCode == 200) {
            final dynamic moveJson = jsonDecode(moveResponse.body);

            pokeMoves.add(PokemonMoveModel(
                id: moveJson["id"],
                name: moveJson["name"],
                accuracy:
                    moveJson["accuracy"] == null ? -1 : moveJson["accuracy"],
                pp: moveJson["pp"],
                power: moveJson["power"] == null ? -1 : moveJson["power"],
                type: moveJson["type"]["name"]));
          } else {
            throw Exception(
                "Status code ${moveResponse.statusCode} when fetching move $name");
          }
        } catch (e) {
          print(e);
          throw HttpException("Could not load moveResponse from given url");
        }
      }

      return pokeMoves;
    } else {
      throw Exception("Falha em retornar os moves do pokemon $pokemonIndex");
    }
  } on SocketException catch (e) {
    print(e);
    print("No internet connection");
    return [];
  } catch (e) {
    print(e);
    return [];
  }
}
