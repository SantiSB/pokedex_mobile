import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Pokemon> _favorites = [];

  List<Pokemon> get favorites => _favorites;

  void addFavorite(Pokemon pokemon) {
    _favorites.add(pokemon);
    notifyListeners();
  }

  void removeFavorite(Pokemon pokemon) {
    _favorites.remove(pokemon);
    notifyListeners();
  }
}
