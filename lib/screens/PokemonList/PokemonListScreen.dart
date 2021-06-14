import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:livefarm_flutter_test/components/PokemonCard.dart';
import 'package:livefarm_flutter_test/controllers/PokemonList.dart';
import 'package:livefarm_flutter_test/services/Extensions/stringCapitalize.dart';

class PokemonListScreen extends StatefulWidget {
  static const routeName = "/";

  PokemonListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final pokemonList = PokemonList();
  int lastListSize = 0;

  @override
  void initState() {
    super.initState();
    pokemonList.populatePokemonList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: DropdownButton(
                underline: Container(),
                icon: Icon(
                  Icons.sort,
                  color: Colors.white,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      pokemonList.sortPokemonList(newValue);
                    }
                  });
                },
                items: <String>["id+", "id-", "weight+", "weight-"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return (DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value.substring(0, value.length - 1).inCaps),
                          () {
                            if (value.endsWith("+")) {
                              return Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black87,
                              );
                            } else {
                              return Icon(
                                Icons.arrow_drop_up,
                                color: Colors.black87,
                              );
                            }
                          }()
                        ]),
                  ));
                }).toList(),
              )),
        ],
      ),
      body: new Scrollbar(
        child: Observer(
          builder: (_) {
            return NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return PokemonCard(
                      pokemon: pokemonList.pokemonByIndex(index));
                },
                itemCount: pokemonList.length,
              ),
            );
          },
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter == 0 &&
          lastListSize < pokemonList.length) {
        pokemonList.addPokemons();
        lastListSize = pokemonList.length;
      }
    }
    return false;
  }
}
