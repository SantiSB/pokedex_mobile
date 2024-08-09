// Importación de las librerías necesarias
import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';
import 'package:pokedex/src/providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatelessWidget {
  final Pokemon pokemon; // Pokémon que se va a mostrar

  const DetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    // Accede al FavoritesProvider para obtener la lista de favoritos
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(pokemon.imageUrl), // Muestra la imagen del Pokémon
            Text(pokemon.name, style: const TextStyle(fontSize: 24)),
            IconButton(
              icon: Icon(
                // Si el Pokémon ya está en favoritos, corazón lleno; si no, corazón vacío
                favoritesProvider.favorites.contains(pokemon)
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 30,
                color: Colors.red,
              ),
              onPressed: () {
                if (favoritesProvider.favorites.contains(pokemon)) {
                  // Si el Pokémon está en favoritos, lo elimina
                  favoritesProvider.removeFavorite(pokemon);
                } else {
                  // Si el Pokémon no está en favoritos, lo agrega
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
