import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/screens/Pokemon/PokemonScreen.dart';
import 'package:livefarm_flutter_test/screens/PokemonList/PokemonListScreen.dart';

void main() async {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: PokemonListScreen.routeName,
      routes: {
        PokemonListScreen.routeName: (context) => PokemonListScreen(
              title: 'Home',
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == PokemonScreen.routeName) {
          final args = settings.arguments as PokemonModel;
          return MaterialPageRoute(builder: (context) {
            return PokemonScreen(pokemon: args);
          });
        }
      },
    );
  }
}
