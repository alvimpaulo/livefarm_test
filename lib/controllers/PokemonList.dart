import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/services/database/getPokemon.dart';
import 'package:mobx/mobx.dart';

part 'PokemonList.g.dart';

class PokemonList = PokemonListBase with _$PokemonList;

abstract class PokemonListBase with Store {
  @observable
  ObservableList<PokemonModel> pokemonList = ObservableList<PokemonModel>();

  @computed
  int get length => pokemonList.length;

  @computed
  String name(int i) => pokemonList[i].name;

  @computed
  PokemonModel pokemonByIndex(int i) => pokemonList[i];

  @action
  Future<void> populatePokemonList() async {
    for (int i = 1; i < 5; i++) {
      try {
        PokemonModel currentPokemon = await getPokemon(i);
        pokemonList.add(currentPokemon);
      } catch (ex) {
        print(ex);
      }
    }
  }

  @action
  Future<void> addPokemons() async {
    int pokemonsSize = pokemonList.length;
    for (int i = pokemonsSize; i < pokemonsSize + 5; i++) {
      try {
        PokemonModel currentPokemon = await getPokemon(i);
        pokemonList.add(currentPokemon);
      } catch (ex) {
        print(ex);
      }
    }
  }

  @action
  void sortPokemonList(String value) {
    switch (value) {
      case "id":
        pokemonList.sort((first, second) => first.id.compareTo(second.id));
        print("sorted by id");
        print(pokemonList[0].name);
        break;
      case "weight":
        pokemonList
            .sort((first, second) => first.weight.compareTo(second.weight));
        print("sorted by weight");
        print(pokemonList[0].name);
        break;
    }
  }
}
