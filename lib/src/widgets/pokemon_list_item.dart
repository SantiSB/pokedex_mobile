import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';
import 'package:pokedex/src/screens/detail_screen.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class PokemonListItem extends StatelessWidget {
  final Pokemon pokemon; // Pokémon que se va a mostrar

  // Callback opcional que se ejecuta cuando se presiona el botón de favoritos
  final VoidCallback? onFavoriteToggle;

  const PokemonListItem(
      {super.key, required this.pokemon, this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    // Accede al FavoritesProvider para gestionar los favoritos
    final favoritesProvider = context.watch<FavoritesProvider>();

    return ListTile(
      leading: Image.network(pokemon.imageUrl), // Imagen del pokemon
      title: Text(pokemon.name),
      trailing: IconButton(
        icon: Icon(
          // Icono de corazón lleno si el Pokémon está en favoritos, o corazón vacío si no lo está
          favoritesProvider.favorites.contains(pokemon)
              ? Icons.favorite
              : Icons.favorite_border,
        ),
        onPressed: () {
          if (favoritesProvider.favorites.contains(pokemon)) {
            // Si el Pokémon ya está en favoritos, lo elimina
            favoritesProvider.removeFavorite(pokemon);
          } else {
            // Si el Pokémon no está en favoritos, lo agrega
            favoritesProvider.addFavorite(pokemon);
          }
          // Si se ha pasado un callback para onFavoriteToggle, lo ejecuta
          if (onFavoriteToggle != null) {
            onFavoriteToggle!();
          }
        },
      ),
      onTap: () {
        // Navega a la pantalla de detalles del Pokémon al tocar el ítem
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
