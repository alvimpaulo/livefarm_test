import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/components/MoveCard.dart';
import 'package:livefarm_flutter_test/models/PokemonModel.dart';
import 'package:livefarm_flutter_test/models/PokemonMoveModel.dart';
import 'package:livefarm_flutter_test/services/Extensions/stringCapitalize.dart';
import 'package:livefarm_flutter_test/services/database/getMoves.dart';

class PokemonScreen extends StatefulWidget {
  static const routeName = "/pokemon";
  final PokemonModel pokemon;

  PokemonScreen({Key? key, required this.pokemon}) : super(key: key);

  @override
  _PokemonScreenState createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  late Future<List<PokemonMoveModel>> futureMoves;

  @override
  void initState() {
    super.initState();
    futureMoves = getMoves(widget.pokemon.id);
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
      body: ListView(
        children: [
          CachedNetworkImage(
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              imageUrl: widget.pokemon.frontHighQuality),
          Center(
            child: Text("Abilities"),
          ),
          Container(
            child: CarouselSlider(
              items: widget.pokemon.abilities
                  .map((ability) => Center(
                        child: Text(
                          "${ability.name} : ${ability.slot}",
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
              options: CarouselOptions(height: 50),
            ),
          ),
          Center(child: Text("Stats")),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 2,
              children: widget.pokemon.stats
                  .map((stat) => Center(
                          child: Text(
                        "${stat.name.allInCaps} : ${stat.baseStat}",
                        textAlign: TextAlign.center,
                      )))
                  .toList(),
            ),
          ),
          FutureBuilder<List<PokemonMoveModel>>(
              future: futureMoves,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: (GridView.count(
                      crossAxisCount: 4,
                      childAspectRatio: 1.5,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data!
                          .map((move) => MoveCard(move: move))
                          .toList(),
                    )),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(child: CircularProgressIndicator());
              })
        ],
      ),
    ));
  }
}
