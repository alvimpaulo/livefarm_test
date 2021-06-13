import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/services/Extensions/stringCapitalize.dart';

class PokemonScreen extends StatefulWidget {
  static const routeName = "/pokemon";
  final PokemonModel pokemon;

  PokemonScreen({Key? key, required this.pokemon}) : super(key: key);

  @override
  _PokemonScreenState createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemon.name.inCaps),
      ),
      body: Center(
        child: Text("Informações do pokemon"),
      ),
    ));
  }
}
