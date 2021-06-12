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

Future<Database> _getDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), "pokemon_database.db"),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE pokemon(id INTEGER PRIMARY KEY, name TEXT, img_pixel_art TEXT, img_high_quality TEXT, stats TEXT, abilities TEXT )',
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
    print(controller.position.extentAfter);
    if (controller.position.extentAfter < 500) {
      setState(() {
        items.addAll(new List.generate(15, (index) => items.length + 1));
      });
    }
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat(this.name, this.baseStat);

  Map toJson() => {
        'name': name,
        'baseStat': baseStat,
      };

  factory PokemonStat.fromJson(dynamic json) {
    return PokemonStat(json["name"], json["baseStat"]);
  }
}

class PokemonAbility {
  final String name;
  final int slot;

  PokemonAbility(this.name, this.slot);

  Map toJson() => {
        'name': name,
        'slot': slot,
      };

  factory PokemonAbility.fromJson(dynamic json) {
    return PokemonAbility(json["name"], json["slot"]);
  }
}

class Pokemon {
  final int id;
  final String name;
  final String frontPixelArt;
  final String frontHighQuality;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;

  Pokemon(this.id, this.name, this.frontPixelArt, this.frontHighQuality,
      this.stats, this.abilities);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "img_pixel_art": frontPixelArt,
      "img_high_quality": frontHighQuality,
      "stats": jsonEncode(stats),
      "abilities": jsonEncode(abilities)
    };
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    List<PokemonStat> pokeStats = [];
    List<PokemonAbility> pokeAbilities = [];

    List<dynamic> stats = json["stats"];
    stats.forEach((stat) {
      pokeStats.add(PokemonStat(stat["stat"]["name"], stat["base_stat"]));
    });

    List<dynamic> abilities = json["abilities"];
    abilities.forEach((ability) {
      pokeAbilities
          .add(PokemonAbility(ability["ability"]["name"], ability["slot"]));
    });

    return (Pokemon(
        json["id"],
        json["name"],
        json["sprites"]["front_default"],
        json["sprites"]["other"]["official-artwork"]["front_default"],
        pokeStats,
        pokeAbilities));
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    List stats = jsonDecode(map["stats"]);
    List<PokemonStat> pokeStats =
        stats.map((json) => PokemonStat.fromJson(json)).toList();

    List abilities = jsonDecode(map["abilities"]);
    List<PokemonAbility> pokeAbilities =
        abilities.map((json) => PokemonAbility.fromJson(json)).toList();

    return (Pokemon(map["id"], map["name"], map["img_pixel_art"],
        map["img_high_quality"], pokeStats, pokeAbilities));
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

  Future<Pokemon> getPokemon() async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps =
          await db.query("pokemon", where: "id = ${widget.index}");

      return Pokemon.fromMap(maps[0]);
    } catch (ex) {
      print(ex);
      print("Could not find ${widget.index} in the database");
      final Pokemon currentPoke = await fetchPokemon();
      await insertPokemon(currentPoke);
      return currentPoke;
    }
  }

  // Define a function that inserts pokemons into the database
  Future<void> insertPokemon(Pokemon pokemon) async {
    try {
      final Database db = await _getDatabase();

      await db.insert(
        "pokemon",
        pokemon.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (ex) {
      print(ex);
      return;
    }
  }

  Future<Pokemon> fetchPokemon() async {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon/${widget.index}"));
    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Falha em retornar o pokemon ${widget.index}");
    }
  }

  @override
  void initState() {
    super.initState();
    futurePokemon = getPokemon();
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
