import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

Future<Database> _getMoveDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "moves_database.db"),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE moves(name TEXT PRIMARY KEY, id INTEGER, accuracy INTEGER, pp INTEGER, power INTEGER)',
      );
    },
    version: 1,
  );
}

Future<Database> _getPokemonDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "pokemons_database.db"),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE pokemons(id INTEGER PRIMARY KEY, name TEXT, img_pixel_art TEXT, img_high_quality TEXT, stats TEXT, abilities TEXT)',
      );
    },
    version: 1,
  );
}

Future<Database> _getPokemonsMovesDatabase() async {
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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeDex',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: HomePage(title: 'Home'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController controller = ScrollController();
  List<int> items = new List.generate(15, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Scrollbar(
        child: new ListView.builder(
          controller: controller,
          itemBuilder: (context, index) {
            return PokemonCard(index: index + 1);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  void _scrollListener() {
    // print(controller.position.extentAfter);
    if (controller.position.extentAfter < 800) {
      setState(() {
        items.addAll(new List.generate(15, (index) => items.length + 1));
      });
    }
  }
}

class PokemonMove {
  final int id;
  final String name;
  final int accuracy;
  final int pp;
  final int power;

  PokemonMove({
    required this.id,
    required this.name,
    required this.accuracy,
    required this.pp,
    required this.power,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name.replaceAll("-", "_"),
      "accuracy": accuracy,
      "pp": pp,
      "power": power
    };
  }

  Map toJson() => {
        "id": id,
        "name": name.replaceAll("-", "_"),
        "accuracy": accuracy,
        "pp": pp,
        "power": power,
      };

  factory PokemonMove.fromJson(dynamic json) {
    return PokemonMove(
      id: json["id"],
      name: json["name"],
      accuracy: json["accuracy"],
      pp: json["pp"],
      power: json["power"],
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({required this.name, required this.baseStat});

  Map toJson() => {
        'name': name,
        'baseStat': baseStat,
      };

  factory PokemonStat.fromJson(dynamic json) {
    return PokemonStat(name: json["name"], baseStat: json["baseStat"]);
  }
}

class PokemonAbility {
  final String name;
  final int slot;

  PokemonAbility({required this.name, required this.slot});

  Map toJson() => {
        'name': name,
        'slot': slot,
      };

  factory PokemonAbility.fromJson(dynamic json) {
    return PokemonAbility(name: json["name"], slot: json["slot"]);
  }
}

class Pokemon {
  final int id;
  final String name;
  final String frontPixelArt;
  final String frontHighQuality;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;

  Pokemon({
    required this.id,
    required this.name,
    required this.frontPixelArt,
    required this.frontHighQuality,
    required this.stats,
    required this.abilities,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "img_pixel_art": frontPixelArt,
      "img_high_quality": frontHighQuality,
      "stats": jsonEncode(stats),
      "abilities": jsonEncode(abilities),
    };
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    List<PokemonStat> pokeStats = [];
    List<PokemonAbility> pokeAbilities = [];

    List<dynamic> stats = json["stats"];
    stats.forEach((stat) {
      pokeStats.add(
          PokemonStat(name: stat["stat"]["name"], baseStat: stat["base_stat"]));
    });

    List<dynamic> abilities = json["abilities"];
    abilities.forEach((ability) {
      pokeAbilities.add(PokemonAbility(
          name: ability["ability"]["name"], slot: ability["slot"]));
    });

    return (Pokemon(
      id: json["id"],
      name: json["name"],
      frontPixelArt: json["sprites"]["front_default"],
      frontHighQuality: json["sprites"]["other"]["official-artwork"]
          ["front_default"],
      stats: pokeStats,
      abilities: pokeAbilities,
    ));
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    List stats = jsonDecode(map["stats"]);
    List<PokemonStat> pokeStats =
        stats.map((json) => PokemonStat.fromJson(json)).toList();

    List abilities = jsonDecode(map["abilities"]);
    List<PokemonAbility> pokeAbilities =
        abilities.map((json) => PokemonAbility.fromJson(json)).toList();

    return (Pokemon(
      id: map["id"],
      name: map["name"],
      frontPixelArt: map["img_pixel_art"],
      frontHighQuality: map["img_high_quality"],
      stats: pokeStats,
      abilities: pokeAbilities,
    ));
  }
}

class PokemonCard extends StatefulWidget {
  PokemonCard({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _PokemonCardState createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late Future<Pokemon> futurePokemon;
  late Future<List<PokemonMove>> futureMoves;

  Future<Pokemon> getPokemon() async {
    try {
      final Database db = await _getPokemonDatabase();
      final List<Map<String, dynamic>> maps = await db
          .query("pokemons", where: "id = ?", whereArgs: [widget.index]);
      if (maps.length >= 1)
        return Pokemon.fromMap(maps[0]);
      else
        throw Exception("Could not find ${widget.index} in the database");
    } catch (ex) {
      print(ex);
      final Pokemon currentPoke = await fetchPokemon();
      await insertPokemon(currentPoke);
      return currentPoke;
    }
  }

  Future<List<PokemonMove>> getMoves() async {
    try {
      final Database movesDb = await _getMoveDatabase();
      final Database pokemonsMovesDb = await _getPokemonsMovesDatabase();
      List<PokemonMove> movesList = [];

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
          movesList.add(PokemonMove.fromJson(moveJson));
        }
        return movesList;
      } else {
        throw Exception(
            "Could not find moves for ${widget.index} in the database");
      }
    } catch (ex) {
      print(ex);
      final List<PokemonMove> currentMoves = await fetchMoves();
      await insertMoves(currentMoves);
      return currentMoves;
    }
  }

  // Define a function that inserts pokemons into the database
  Future<void> insertPokemon(Pokemon pokemon) async {
    try {
      final Database pokemonDb = await _getPokemonDatabase();

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

  Future<void> insertMoves(List<PokemonMove> moves) async {
    try {
      final Database moveDb = await _getMoveDatabase();
      final Database pokemonsMovesDb = await _getPokemonsMovesDatabase();

      for (PokemonMove move in moves) {
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

  Future<Pokemon> fetchPokemon() async {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.index}"));
    if (response.statusCode == 200) {
      final dynamic pokemonJson = jsonDecode(response.body);

      return Pokemon.fromJson(pokemonJson);
    } else {
      throw Exception("Falha em retornar o pokemon ${widget.index}");
    }
  }

  Future<List<PokemonMove>> fetchMoves() async {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.index}"));
    if (response.statusCode == 200) {
      final dynamic pokemonJson = jsonDecode(response.body);

      final List<dynamic> movesJson = pokemonJson["moves"];
      final List<PokemonMove> pokeMoves = [];

      for (dynamic move in movesJson) {
        final String name = move["move"]["name"];
        final String url = move["move"]["url"];

        final moveResponse = await http.get(Uri.parse(url));
        if (moveResponse.statusCode == 200) {
          final dynamic moveJson = jsonDecode(moveResponse.body);

          pokeMoves.add(PokemonMove(
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
    return FutureBuilder<Pokemon>(
        future: futurePokemon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Card(
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
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Card();
        });
  }
}
