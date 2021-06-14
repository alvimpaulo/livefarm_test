// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PokemonList.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PokemonList on PokemonListBase, Store {
  final _$pokemonListAtom = Atom(name: 'PokemonListBase.pokemonList');

  @override
  ObservableList<PokemonModel> get pokemonList {
    _$pokemonListAtom.reportRead();
    return super.pokemonList;
  }

  @override
  set pokemonList(ObservableList<PokemonModel> value) {
    _$pokemonListAtom.reportWrite(value, super.pokemonList, () {
      super.pokemonList = value;
    });
  }

  final _$populatePokemonListAsyncAction =
      AsyncAction('PokemonListBase.populatePokemonList');

  @override
  Future<void> populatePokemonList() {
    return _$populatePokemonListAsyncAction
        .run(() => super.populatePokemonList());
  }

  final _$PokemonListBaseActionController =
      ActionController(name: 'PokemonListBase');

  @override
  void sortPokemonList(String value) {
    final _$actionInfo = _$PokemonListBaseActionController.startAction(
        name: 'PokemonListBase.sortPokemonList');
    try {
      return super.sortPokemonList(value);
    } finally {
      _$PokemonListBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pokemonList: ${pokemonList}
    ''';
  }
}
