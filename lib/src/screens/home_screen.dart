// Importación de las librerías necesarias
import 'package:flutter/material.dart';
import 'package:pokedex/src/models/pokemon.dart';
import 'package:pokedex/src/services/api_service.dart';
import 'package:pokedex/src/widgets/pokemon_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// Estado de la pantalla HomeScreen, donde se maneja la lógica y el estado
class HomeScreenState extends State<HomeScreen> {
  // Instancia del servicio de API para manejar las peticiones
  final ApiService apiService = ApiService();
  // Lista que almacena todos los Pokémons cargados
  final List<Pokemon> pokemons = [];
  // Lista que almacena los nombres de todos los Pokémons
  final List<String> allPokemonNames = [];
  // Lista que almacena los Pokémons filtrados según la búsqueda
  final List<Pokemon> filteredPokemons = [];
  // Variable que indica si se está cargando más contenido
  bool isLoading = false;
  // Variable que indica si hay más Pokémons para cargar
  bool hasMore = true;
  // Desplazamiento actual para la paginación
  int offset = 0;
  // Límite de Pokémons a cargar por cada petición
  final int limit = 100;
  // Consulta de búsqueda ingresada por el usuario
  String query = '';

  @override
  void initState() {
    super.initState();
    // Carga todos los nombres de los Pokémons al iniciar la pantalla
    loadAllPokemonNames();
    // Carga los primeros Pokémons al iniciar la pantalla
    fetchMorePokemons();
  }

  // Método para cargar todos los nombres de los Pokémons desde la API
  Future<void> loadAllPokemonNames() async {
    try {
      // Obtiene los nombres de los Pokémons desde el servicio de API
      final names = await apiService.fetchAllPokemonNames();
      setState(() {
        // Agrega los nombres a la lista local
        allPokemonNames.addAll(names);
      });
    } catch (e) {
      // Imprime un mensaje de error en caso de falla
      print('Error loading all pokemon names: $e');
    }
  }

  // Método para cargar más Pokémons desde la API, con paginación
  Future<void> fetchMorePokemons() async {
    // Si ya se está cargando, salir del método para evitar duplicados
    if (isLoading) return;
    setState(() {
      isLoading = true; // Establece el estado de carga
    });
    try {
      // Obtiene los nuevos Pokémons desde el servicio de API
      final newPokemons =
          await apiService.fetchPokemons(offset: offset, limit: limit);
      setState(() {
        // Incrementa el offset para la siguiente carga
        offset += limit;
        // Agrega los nuevos Pokémons a la lista local si no están duplicados
        for (final pokemon in newPokemons) {
          if (!pokemons.any((p) => p.name == pokemon.name)) {
            pokemons.add(pokemon);
          }
        }
        // Filtra los Pokémons después de agregarlos
        filterPokemons();
        // Verifica si hay más Pokémons para cargar
        hasMore = newPokemons.length == limit;
      });
    } catch (e) {
      // Imprime un mensaje de error en caso de falla
      print('Error loading more pokemons: $e');
    } finally {
      setState(() {
        // Finaliza el estado de carga
        isLoading = false;
      });
    }
  }

  // Método para filtrar los Pokémons según la consulta de búsqueda
  void filterPokemons() {
    setState(() {
      if (query.isEmpty) {
        // Si no hay consulta, muestra todos los Pokémons
        filteredPokemons.clear();
        filteredPokemons.addAll(pokemons);
      } else {
        // Filtra los nombres de Pokémons que coincidan con la consulta
        final lowerCaseQuery = query.toLowerCase();
        final filteredNames = allPokemonNames
            .where((name) => name.contains(lowerCaseQuery))
            .toList();
        filteredPokemons.clear();
        // Agrega a la lista filtrada solo los Pokémons que coincidan con los nombres filtrados
        for (final pokemon in pokemons) {
          if (filteredNames.contains(pokemon.name.toLowerCase())) {
            filteredPokemons.add(pokemon);
          }
        }
        // Si no se encuentran todos los Pokémons filtrados, se cargan desde la API
        if (filteredPokemons.length < filteredNames.length) {
          fetchFilteredPokemons(filteredNames);
        } else {
          hasMore = false; // No hay más Pokémon para cargar
        }
      }
    });
  }

  // Método para cargar los Pokémons filtrados que no están en la lista local
  Future<void> fetchFilteredPokemons(List<String> filteredNames) async {
    for (final name in filteredNames) {
      // Si un Pokémon filtrado no está en la lista local, se carga desde la API
      if (!pokemons.any((pokemon) => pokemon.name.toLowerCase() == name)) {
        try {
          // Carga el Pokémon desde la API
          final response = await apiService.fetchPokemons(
              offset: allPokemonNames.indexOf(name), limit: 1);
          setState(() {
            // Agrega el Pokémon a la lista local si no está duplicado
            for (final pokemon in response) {
              if (!pokemons.any((p) => p.name == pokemon.name)) {
                pokemons.add(pokemon);
              }
            }
            // Vuelve a filtrar los Pokémons
            filterPokemons();
          });
        } catch (e) {
          // Imprime un mensaje de error en caso de falla
          print('Error loading filtered pokemon: $e');
        }
      }
    }
    setState(() {
      // Establece hasMore a false, ya que no hay más Pokémons para cargar
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
              // Navega a la pantalla de favoritos
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de texto para buscar Pokémons por nombre
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Pokémon',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  // Actualiza la consulta de búsqueda con el valor ingresado
                  query = value;
                  // Restablece el estado de carga cuando se cambia la búsqueda
                  hasMore = true;
                  // Filtra los Pokémons según la nueva consulta
                  filterPokemons();
                });
              },
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Comprueba si se ha llegado al final de la lista y si hay más Pokémons para cargar
                if (!isLoading &&
                    hasMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  // Carga más Pokémons cuando se alcanza el final de la lista
                  fetchMorePokemons();
                }
                return false;
              },
              // Construye la lista de Pokémons
              child: ListView.builder(
                // Determina la cantidad de elementos en la lista
                itemCount: filteredPokemons.length + (hasMore ? 1 : 0),
                // Construye cada ítem de la lista
                itemBuilder: (context, index) {
                  if (index == filteredPokemons.length) {
                    // Muestra un indicador de carga si hay más Pokémons para cargar
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    // Muestra un ítem de la lista con la información del Pokémon
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
