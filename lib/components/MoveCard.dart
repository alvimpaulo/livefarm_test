import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/models/PokemonMoveModel.dart';
import 'package:livefarm_flutter_test/services/Extensions/stringCapitalize.dart';

class MoveCard extends StatefulWidget {
  MoveCard({Key? key, required this.move}) : super(key: key);

  final PokemonMoveModel move;

  @override
  _MoveCardState createState() => _MoveCardState();
}

class _MoveCardState extends State<MoveCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        color: () {
          switch (widget.move.type) {
            case "normal":
              return Colors.white;
            case "fight":
              return Colors.pink;
            case "flying":
              return Colors.lightBlue;
            case "poison":
              return Colors.purple;
            case "ground":
              return Colors.amber;
            case "rock":
              return Colors.white38;
            case "bug":
              return Colors.lightGreenAccent;
            case "ghost":
              return Colors.deepPurple;
            case "steel":
              return Colors.grey;
            case "fire":
              return Colors.deepOrange;
            case "water":
              return Colors.blue;
            case "grass":
              return Colors.green;
            case "electric":
              return Colors.yellow;
            case "psychic":
              return Colors.pinkAccent;
            case "ice":
              return Colors.lightBlueAccent;
            case "dragon":
              return Colors.indigo;
            case "dark":
              return Colors.blueGrey;
            case "fairy":
              return Colors.pink;
          }
        }(),
        child: Column(
          children: [
            Center(
              child: Text(widget.move.name.allInCaps),
            ),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                () {
                  return (widget.move.pp == -1
                      ? Text("PP : N/A")
                      : Text("PP : ${widget.move.pp}"));
                }(),
                () {
                  return (widget.move.accuracy == -1
                      ? Text("Accuracy : N/A")
                      : Text("Accuracy : ${widget.move.accuracy}"));
                }(),
                () {
                  return (widget.move.power == -1
                      ? Text("Power : N/A")
                      : Text("Power : ${widget.move.power}"));
                }(),
                Text("Type : ${widget.move.type.inCaps}")
              ],
            ),
          ],
        ),
      ),
    );
  }
}
