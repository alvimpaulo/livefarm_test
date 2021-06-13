import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/screens/Pokemon/PokemonScreen.dart';
import 'package:livefarm_flutter_test/services/database/getPokemon.dart';

class PokemonCard extends StatefulWidget {
  PokemonCard({Key? key, required this.index}) : super(key: key);

  final int index;

  @override
  _PokemonCardState createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  late Future<PokemonModel> futurePokemon;

  @override
  void initState() {
    super.initState();
    futurePokemon = getPokemon(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonModel>(
        future: futurePokemon,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, PokemonScreen.routeName,
                    arguments: snapshot.data);
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: CachedNetworkImage(
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        imageUrl: snapshot.data!.frontPixelArt,
                      ),
                      title: Text(
                          "${snapshot.data!.name[0].toUpperCase()}${snapshot.data!.name.substring(1)}"),
                      subtitle: Text("Pokemon de Número ${snapshot.data!.id}"),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Card();
        });
  }
}
