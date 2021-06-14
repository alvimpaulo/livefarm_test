import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/models/PokemonAbilityModel.dart';
import 'package:livefarm_flutter_test/services/Extensions/stringCapitalize.dart';

class AbilityCard extends StatefulWidget {
  AbilityCard({Key? key, required this.ability}) : super(key: key);

  final PokemonAbilityModel ability;

  @override
  _AbilityCardState createState() => _AbilityCardState();
}

class _AbilityCardState extends State<AbilityCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Center(
          child: Text(
            widget.ability.name.allInCaps,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
