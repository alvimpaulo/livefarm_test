import 'package:flutter/material.dart';
import 'package:livefarm_flutter_test/components/PokemonCard.dart';

class PokemonListScreen extends StatefulWidget {
  static const routeName = "/";
  PokemonListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  ScrollController controller = ScrollController();
  List<int> items = new List.generate(15, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Scrollbar(
        child: new ListView.builder(
          controller: controller,
          itemBuilder: (context, index) {
            return PokemonCard(index: index + 1);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  void _scrollListener() {
    // print(controller.position.extentAfter);
    if (controller.position.extentAfter < 800) {
      setState(() {
        items.addAll(new List.generate(15, (index) => items.length + 1));
      });
    }
  }
}
