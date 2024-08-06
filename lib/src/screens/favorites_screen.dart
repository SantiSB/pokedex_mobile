import 'package:flutter/material.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:pokedex/src/widgets/pokemon_list_item.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final favoritePokemons = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ListView.builder(
        itemCount: favoritePokemons.length,
        itemBuilder: (context, index) {
          final pokemon = favoritePokemons[index];
          return PokemonListItem(
            pokemon: pokemon,
            onFavoriteToggle: () {
              // Actualiza la pantalla después de eliminar el Pokémon de favoritos
              favoritesProvider.removeFavorite(pokemon);
            },
          );
        },
      ),
    );
  }
}
