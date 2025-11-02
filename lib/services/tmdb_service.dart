import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDBService {
  final String? apiKey = dotenv.env['TMDB_API_KEY'];

  Future<List<dynamic>> getNowPlayingMovies(String countryCode) async {
    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&language=es-ES&region=$countryCode&page=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al obtener cartelera: ${response.statusCode}');
    }
  }
}
