import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/services/database/getPokemon.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'PokemonList.g.dart';

class PokemonList = PokemonListBase with _$PokemonList;

abstract class PokemonListBase with Store {
  @observable
  ObservableList<PokemonModel> pokemonList = ObservableList<PokemonModel>();

  @computed
  int get length => pokemonList.length;

  String name(int i) => pokemonList[i].name;

  PokemonModel pokemonByIndex(int i) => pokemonList[i];

  @action
  Future<void> populatePokemonList() async {
    for (int i = 1; i < 10; i++) {
      try {
        PokemonModel currentPokemon = await getPokemon(i);
        try {
          pokemonList.firstWhere((pokemon) => currentPokemon.id == pokemon.id);
        } on StateError {
          pokemonList.add(currentPokemon);
        }
      } catch (ex) {
        print(ex);
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sortMethod = prefs.getString("sort_method");
    if (sortMethod == null) {
      return;
    } else {
      sortPokemonList(prefs.getString("sort_method")!);
    }
  }

  @action
  Future<void> addPokemons() async {
    int pokemonsSize = pokemonList.length;
    for (int i = pokemonsSize + 1; i < pokemonsSize + 5; i++) {
      try {
        PokemonModel currentPokemon = await getPokemon(i);
        try {
          pokemonList.firstWhere((pokemon) => currentPokemon.id == pokemon.id);
        } on StateError {
          pokemonList.add(currentPokemon);
        }
      } catch (ex) {
        print(ex);
      }
    }
  }

  @action
  void sortPokemonList(String value) {
    switch (value) {
      case "id-":
        pokemonList.sort((first, second) => first.id.compareTo(second.id));
        break;
      case "id+":
        pokemonList.sort((first, second) => second.id.compareTo(first.id));
        break;
      case "weight-":
        pokemonList
            .sort((first, second) => first.weight.compareTo(second.weight));
        break;
      case "weight+":
        pokemonList
            .sort((first, second) => second.weight.compareTo(first.weight));
        break;
    }

    updateSortMethod(value);
  }

  Future<void> updateSortMethod(String sortMethod) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("sort_method", sortMethod);
  }
}
