class PokemonStatModel {
  final String name;
  final int baseStat;

  PokemonStatModel({required this.name, required this.baseStat});

  Map toJson() => {
        'name': name,
        'baseStat': baseStat,
      };

  factory PokemonStatModel.fromJson(dynamic json) {
    return PokemonStatModel(name: json["name"], baseStat: json["baseStat"]);
  }
}
