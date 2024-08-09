import 'package:flutter/material.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:pokedex/src/widgets/pokemon_list_item.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accede al FavoritesProvider para obtener la lista de favoritos
    final favoritesProvider = context.watch<FavoritesProvider>();
    // Almacena la lista de Pokémons favoritos
    final favoritePokemons = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ListView.builder(
        // Define cuántos ítems tendrá la lista (longitud de la lista de favoritos)
        itemCount: favoritePokemons.length,
        // Construye cada ítem de la lista
        itemBuilder: (context, index) {
          // Obtiene el Pokémon correspondiente al índice actual
          final pokemon = favoritePokemons[index];
          // Retorna un widget personalizado para mostrar el Pokémon en la lista
          return PokemonListItem(
            pokemon: pokemon,
            onFavoriteToggle: () {
              // Elimina el Pokémon de la lista de favoritos cuando se presiona el botón
              favoritesProvider.removeFavorite(pokemon);
            },
          );
        },
      ),
    );
  }
}
