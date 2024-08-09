import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';

// ChangeNotifier es una clase de Flutter que permite notificar a los widgets que están escuchando cambios
class FavoritesProvider extends ChangeNotifier {
  // Lista privada que almacena los Pokémons favoritos
  final List<Pokemon> _favorites = [];

  // Getter público para acceder a la lista de favoritos desde fuera de esta clase
  // No permite modificar directamente la lista, solo acceder a ella
  List<Pokemon> get favorites => _favorites;

  // Método para agregar un Pokémon a la lista de favoritos y notificar a los listeners
  void addFavorite(Pokemon pokemon) {
    _favorites.add(pokemon);
    notifyListeners();
  }

  // Método para eliminar un Pokémon de la lista de favoritos y notificar a los listeners
  void removeFavorite(Pokemon pokemon) {
    _favorites.remove(pokemon);
    notifyListeners();
  }
}
