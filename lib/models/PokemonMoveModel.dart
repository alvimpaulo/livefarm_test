class PokemonMoveModel {
  final int id;
  final String name;
  final int accuracy;
  final int pp;
  final int power;
  final String type;

  PokemonMoveModel(
      {required this.id,
      required this.name,
      required this.accuracy,
      required this.pp,
      required this.power,
      required this.type});

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

  factory PokemonMoveModel.fromJson(dynamic json) {
    return PokemonMoveModel(
        id: json["id"],
        name: json["name"],
        accuracy: json["accuracy"],
        pp: json["pp"],
        power: json["power"],
        type: json["type"]);
  }
}
