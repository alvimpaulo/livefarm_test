class PokemonAbilityModel {
  final String name;
  final int slot;

  PokemonAbilityModel({required this.name, required this.slot});

  Map toJson() => {
        'name': name,
        'slot': slot,
      };

  factory PokemonAbilityModel.fromJson(dynamic json) {
    try {
      return PokemonAbilityModel(name: json["name"], slot: json["slot"]);
    } catch (e) {
      print("$e in PokemonAbilityModel.fromJson");
    }
    return PokemonAbilityModel(name: "none", slot: -1);
  }
}
