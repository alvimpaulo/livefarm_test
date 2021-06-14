import 'dart:convert';

import 'package:livefarm_flutter_test/models/PokemonAbilityModel.dart';
import 'package:livefarm_flutter_test/models/PokemonStatModel.dart';

class PokemonModel {
  final int id;
  final String name;
  final String frontPixelArt;
  final String frontHighQuality;
  final int weight;
  final List<PokemonStatModel> stats;
  final List<PokemonAbilityModel> abilities;

  PokemonModel({
    required this.id,
    required this.name,
    required this.frontPixelArt,
    required this.frontHighQuality,
    required this.weight,
    required this.stats,
    required this.abilities,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "img_pixel_art": frontPixelArt,
      "img_high_quality": frontHighQuality,
      "weight": weight,
      "stats": jsonEncode(stats),
      "abilities": jsonEncode(abilities),
    };
  }

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    try {
      List<PokemonStatModel> pokeStats = [];
      List<PokemonAbilityModel> pokeAbilities = [];

      List<dynamic> stats = json["stats"];
      stats.forEach((stat) {
        pokeStats.add(PokemonStatModel(
            name: stat["stat"]["name"], baseStat: stat["base_stat"]));
      });

      List<dynamic> abilities = json["abilities"];
      abilities.forEach((ability) {
        pokeAbilities.add(PokemonAbilityModel(
            name: ability["ability"]["name"], slot: ability["slot"]));
      });

      return (PokemonModel(
        id: json["id"],
        name: json["name"],
        frontPixelArt: json["sprites"]["front_default"],
        frontHighQuality: json["sprites"]["other"]["official-artwork"]
            ["front_default"],
        weight: json["weight"],
        stats: pokeStats,
        abilities: pokeAbilities,
      ));
    } catch (e) {
      print("$e on PokemonModel.fromJson");
    }

    return PokemonModel(
        id: -1,
        name: "none",
        frontPixelArt: "none",
        frontHighQuality: "none",
        weight: -1,
        stats: [],
        abilities: []);
  }

  factory PokemonModel.fromMap(Map<String, dynamic> map) {
    try {
      List stats = jsonDecode(map["stats"]);
      List<PokemonStatModel> pokeStats =
          stats.map((json) => PokemonStatModel.fromJson(json)).toList();

      List abilities = jsonDecode(map["abilities"]);
      List<PokemonAbilityModel> pokeAbilities =
          abilities.map((json) => PokemonAbilityModel.fromJson(json)).toList();

      return (PokemonModel(
        id: map["id"],
        name: map["name"],
        frontPixelArt: map["img_pixel_art"],
        frontHighQuality: map["img_high_quality"],
        weight: map["weight"],
        stats: pokeStats,
        abilities: pokeAbilities,
      ));
    } catch (e) {
      print("$e on PokemonModel.fromMap");
    }

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
