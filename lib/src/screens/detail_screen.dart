import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(pokemon.imageUrl),
            Text(pokemon.name, style: const TextStyle(fontSize: 24)),
            IconButton(
              icon: Icon(
                favoritesProvider.favorites.contains(pokemon)
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 30,
                color: Colors.red,
              ),
              onPressed: () {
                if (favoritesProvider.favorites.contains(pokemon)) {
                  favoritesProvider.removeFavorite(pokemon);
                } else {
                  favoritesProvider.addFavorite(pokemon);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
