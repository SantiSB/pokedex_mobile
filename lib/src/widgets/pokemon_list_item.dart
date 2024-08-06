import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';
import 'package:pokedex/src/screens/detail_screen.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class PokemonListItem extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onFavoriteToggle;

  const PokemonListItem(
      {super.key, required this.pokemon, this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    return ListTile(
      leading: Image.network(pokemon.imageUrl),
      title: Text(pokemon.name),
      trailing: IconButton(
        icon: Icon(
          favoritesProvider.favorites.contains(pokemon)
              ? Icons.favorite
              : Icons.favorite_border,
        ),
        onPressed: () {
          if (favoritesProvider.favorites.contains(pokemon)) {
            favoritesProvider.removeFavorite(pokemon);
          } else {
            favoritesProvider.addFavorite(pokemon);
          }
          if (onFavoriteToggle != null) {
            onFavoriteToggle!();
          }
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(pokemon: pokemon),
          ),
        );
      },
    );
  }
}
