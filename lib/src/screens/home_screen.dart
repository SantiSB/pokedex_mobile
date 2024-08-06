import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';
import 'package:pokedex/src/services/api_service.dart';
import 'package:pokedex/src/widgets/pokemon_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final List<Pokemon> pokemons = [];
  final List<String> allPokemonNames = [];
  final List<Pokemon> filteredPokemons = [];
  bool isLoading = false;
  bool hasMore = true;
  int offset = 0;
  final int limit = 100;
  String query = '';

  @override
  void initState() {
    super.initState();
    loadAllPokemonNames();
    fetchMorePokemons();
  }

  Future<void> loadAllPokemonNames() async {
    try {
      final names = await apiService.fetchAllPokemonNames();
      setState(() {
        allPokemonNames.addAll(names);
      });
    } catch (e) {
      print('Error loading all pokemon names: $e');
    }
  }

  Future<void> fetchMorePokemons() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      final newPokemons =
          await apiService.fetchPokemons(offset: offset, limit: limit);
      setState(() {
        offset += limit;
        for (final pokemon in newPokemons) {
          if (!pokemons.any((p) => p.name == pokemon.name)) {
            pokemons.add(pokemon);
          }
        }
        filterPokemons();
        hasMore = newPokemons.length == limit;
      });
    } catch (e) {
      print('Error loading more pokemons: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPokemons() {
    setState(() {
      if (query.isEmpty) {
        filteredPokemons.clear();
        filteredPokemons.addAll(pokemons);
      } else {
        final lowerCaseQuery = query.toLowerCase();
        final filteredNames = allPokemonNames
            .where((name) => name.contains(lowerCaseQuery))
            .toList();
        filteredPokemons.clear();
        for (final pokemon in pokemons) {
          if (filteredNames.contains(pokemon.name.toLowerCase())) {
            filteredPokemons.add(pokemon);
          }
        }
        if (filteredPokemons.length < filteredNames.length) {
          fetchFilteredPokemons(filteredNames);
        } else {
          hasMore = false; // No hay más Pokémon para cargar
        }
      }
    });
  }

  Future<void> fetchFilteredPokemons(List<String> filteredNames) async {
    for (final name in filteredNames) {
      if (!pokemons.any((pokemon) => pokemon.name.toLowerCase() == name)) {
        try {
          final response = await apiService.fetchPokemons(
              offset: allPokemonNames.indexOf(name), limit: 1);
          setState(() {
            for (final pokemon in response) {
              if (!pokemons.any((p) => p.name == pokemon.name)) {
                pokemons.add(pokemon);
              }
            }
            filterPokemons();
          });
        } catch (e) {
          print('Error loading filtered pokemon: $e');
        }
      }
    }
    setState(() {
      hasMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Pokémon',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                  hasMore =
                      true; // Resetear el estado de carga cuando se cambia la búsqueda
                  filterPokemons();
                });
              },
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading &&
                    hasMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  fetchMorePokemons();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: filteredPokemons.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredPokemons.length) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return PokemonListItem(pokemon: filteredPokemons[index]);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
