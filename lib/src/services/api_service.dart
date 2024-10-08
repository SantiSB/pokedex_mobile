import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/src/models/pokemon.dart';

class ApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // Método para obtener todos los nombres de Pokémons
  Future<List<String>> fetchAllPokemonNames() async {
    try {
      // Petición GET para obtener los nombres de todos los Pokémons
      final response =
          await http.get(Uri.parse('$_baseUrl/pokemon?limit=1118'));

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta en formato JSON
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        // Mapea los resultados para extraer los nombres de los Pokémons
        return results
            .map<String>((pokemon) => pokemon['name'] as String)
            .toList();
      } else {
        throw Exception('Failed to load pokemon names');
      }
    } catch (e) {
      print('Error fetching pokemon names: $e');
      throw Exception('Failed to load pokemon names');
    }
  }

  // Método para obtener una lista de Pokémons con detalles
  // Paginación con los parámetros offset y limit
  Future<List<Pokemon>> fetchPokemons({int offset = 0, int limit = 20}) async {
    try {
      // Petición GET para obtener los Pokémons según el offset y limit
      final response = await http
          .get(Uri.parse('$_baseUrl/pokemon?offset=$offset&limit=$limit'));

      if (response.statusCode == 200) {
        // Decodifica el cuerpo de la respuesta en formato JSON
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        // Mapea los resultados para obtener los detalles de cada Pokémon
        List<Future<Pokemon>> futurePokemons = results.map((pokemon) async {
          // Petición GET para obtener los detalles de cada Pokémon individualmente
          final detailResponse = await http.get(Uri.parse(pokemon['url']));
          if (detailResponse.statusCode == 200) {
            // Decodifica los detalles del Pokémon y crea una instancia de Pokemon
            final detailData = json.decode(detailResponse.body);
            return Pokemon.fromJson(detailData);
          } else {
            throw Exception(
                'Failed to load pokemon details for ${pokemon['name']}');
          }
        }).toList();

        // Espera a que todas las peticiones de detalles se completen y retorna la lista de Pokémons
        return Future.wait(futurePokemons);
      } else {
        print(
            'Failed to load pokemons with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load pokemons');
      }
    } catch (e) {
      print('Error fetching pokemons: $e');
      throw Exception('Failed to load pokemons');
    }
  }
}
