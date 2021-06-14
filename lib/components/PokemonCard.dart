import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/screens/Pokemon/PokemonScreen.dart';
import 'package:livefarm_flutter_test/services/Extensions/stringCapitalize.dart';

class PokemonCard extends StatefulWidget {
  PokemonCard({Key? key, required this.pokemon}) : super(key: key);

  final PokemonModel pokemon;

  @override
  _PokemonCardState createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, PokemonScreen.routeName,
            arguments: widget.pokemon);
      },
      child: Container(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: CachedNetworkImage(
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image(
                      image:
                          AssetImage("assets/images/interrogacaoPokemon.png")),
                  imageUrl: widget.pokemon.frontPixelArt,
                ),
                title: Text("${widget.pokemon.name.inCaps}"),
                subtitle: Text("Pokemon id ${widget.pokemon.id}"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
