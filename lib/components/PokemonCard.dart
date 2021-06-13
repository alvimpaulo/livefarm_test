import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/models/PokemonMoveModel.dart';
import 'package:livefarm_flutter_test/screens/Pokemon/PokemonScreen.dart';
import 'package:livefarm_flutter_test/services/database/getMovesDatabase.dart';
import 'package:livefarm_flutter_test/services/database/getPokemonDatabase.dart';
import 'package:livefarm_flutter_test/services/database/getPokemonsMovesDatabase.dart';
import 'package:sqflite/sqflite.dart';

class PokemonCard extends StatefulWidget {
  PokemonCard({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _PokemonCardState createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late Future<PokemonModel> futurePokemon;
  late Future<List<PokemonMoveModel>> futureMoves;

  Future<PokemonModel> getPokemon() async {
    try {
      final Database db = await getPokemonDatabase();
      final List<Map<String, dynamic>> maps = await db
          .query("pokemons", where: "id = ?", whereArgs: [widget.index]);
      if (maps.length >= 1)
        return PokemonModel.fromMap(maps[0]);
      else
        throw Exception("Could not find ${widget.index} in the database");
    } catch (ex) {
      print(ex);
      final PokemonModel currentPoke = await fetchPokemon();
      await insertPokemon(currentPoke);
      return currentPoke;
    }
  }

  Future<List<PokemonMoveModel>> getMoves() async {
    try {
      final Database movesDb = await getMoveDatabase();
      final Database pokemonsMovesDb = await getPokemonsMovesDatabase();
      List<PokemonMoveModel> movesList = [];

      final List<Map<String, dynamic>> movesCurrentPokemon =
          await pokemonsMovesDb.query("pokemons_moves",
              where: "pokemon_id = ?",
              whereArgs: [widget.index],
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
        throw Exception(
            "Could not find moves for ${widget.index} in the database");
      }
    } catch (ex) {
      print(ex);
      final List<PokemonMoveModel> currentMoves = await fetchMoves();
      await insertMoves(currentMoves);
      return currentMoves;
    }
  }

  // Define a function that inserts pokemons into the database
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

  Future<void> insertMoves(List<PokemonMoveModel> moves) async {
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
          {"pokemon_id": widget.index, "move_name": move.name},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (ex) {
      print("Error inserting moves");
      print(ex);
      return;
    }
  }

  Future<PokemonModel> fetchPokemon() async {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.index}"));
    if (response.statusCode == 200) {
      final dynamic pokemonJson = jsonDecode(response.body);

      return PokemonModel.fromJson(pokemonJson);
    } else {
      throw Exception("Falha em retornar o pokemon ${widget.index}");
    }
  }

  Future<List<PokemonMoveModel>> fetchMoves() async {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.index}"));
    if (response.statusCode == 200) {
      final dynamic pokemonJson = jsonDecode(response.body);

      final List<dynamic> movesJson = pokemonJson["moves"];
      final List<PokemonMoveModel> pokeMoves = [];

      for (dynamic move in movesJson) {
        final String name = move["move"]["name"];
        final String url = move["move"]["url"];

        final moveResponse = await http.get(Uri.parse(url));
        if (moveResponse.statusCode == 200) {
          final dynamic moveJson = jsonDecode(moveResponse.body);

          pokeMoves.add(PokemonMoveModel(
            id: moveJson["id"],
            name: moveJson["name"],
            accuracy: moveJson["accuracy"] == null ? -1 : moveJson["accuracy"],
            pp: moveJson["pp"],
            power: moveJson["power"] == null ? -1 : moveJson["power"],
          ));
        } else {
          throw Exception("Falha em retornar o move $name");
        }
      }

      return pokeMoves;
    } else {
      throw Exception("Falha em retornar os moves do pokemon ${widget.index}");
    }
  }

  @override
  void initState() {
    super.initState();
    futurePokemon = getPokemon();
    // futureMoves = getMoves();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonModel>(
        future: futurePokemon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, PokemonScreen.routeName,
                    arguments: snapshot.data);
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: CachedNetworkImage(
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        imageUrl: snapshot.data!.frontPixelArt,
                      ),
                      title: Text(
                          "${snapshot.data!.name[0].toUpperCase()}${snapshot.data!.name.substring(1)}"),
                      subtitle: Text("Pokemon de Número ${snapshot.data!.id}"),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Card();
        });
  }
}
