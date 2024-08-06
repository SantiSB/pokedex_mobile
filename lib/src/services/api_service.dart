import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/src/models/pokemon.dart';

class ApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<String>> fetchAllPokemonNames() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/pokemon?limit=1118'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
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

  Future<List<Pokemon>> fetchPokemons({int offset = 0, int limit = 20}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/pokemon?offset=$offset&limit=$limit'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        List<Future<Pokemon>> futurePokemons = results.map((pokemon) async {
          final detailResponse = await http.get(Uri.parse(pokemon['url']));
          if (detailResponse.statusCode == 200) {
            final detailData = json.decode(detailResponse.body);
            return Pokemon.fromJson(detailData);
          } else {
            throw Exception(
                'Failed to load pokemon details for ${pokemon['name']}');
          }
        }).toList();

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
