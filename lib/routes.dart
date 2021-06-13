import 'package:flutter/widgets.dart';
import 'package:livefarm_flutter_test/screens/Pokemon/PokemonScreen.dart';
import 'package:livefarm_flutter_test/screens/PokemonList/PokemonListScreen.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => PokemonListScreen(title: "Home"),
  "/pokemon": (BuildContext context) => PokemonScreen(),
};
