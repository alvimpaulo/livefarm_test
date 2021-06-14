import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:livefarm_flutter_test/components/AbilityCard.dart';
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
        shrinkWrap: true,
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
                        child: AbilityCard(
                          ability: ability,
                        ),
                      ))
                  .toList(),
              options: CarouselOptions(height: 50),
            ),
          ),
          Container(
              height: 300,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: RadarChart.light(
                  useSides: true,
                  ticks: [0, 51, 102, 153, 104, 155, 206, 255],
                  features: widget.pokemon.stats.map((e) {
                    switch (e.name) {
                      case "speed":
                        return "SPD";
                      case "attack":
                        return "ATK";
                      case "special-attack":
                        return "SPATK";
                      case "hp":
                        return "HP";
                      case "special-defense":
                        return "SPDEF";
                      case "defense":
                        return "DEF";
                      default:
                        return "STAT";
                    }
                  }).toList(),
                  data: [
                    widget.pokemon.stats.map((e) => e.baseStat).toList()
                  ])),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text("Moves"),
            ),
          ),
          FutureBuilder<List<PokemonMoveModel>>(
              future: futureMoves,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: (GridView.count(
                      crossAxisCount: (getBiggerScreenRatio() / 2).ceil(),
                      childAspectRatio: getBiggerScreenRatio() / 5,
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

  double getBiggerScreenRatio() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return (height > width
        ? (height / width) * MediaQuery.of(context).devicePixelRatio
        : (width / height) * MediaQuery.of(context).devicePixelRatio);
  }
}
