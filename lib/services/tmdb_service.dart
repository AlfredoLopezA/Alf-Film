import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/widgets.dart';

final String? apiKey = dotenv.env['TMDB_API_KEY'];

class TMDBService {
  // === 1. Películas en cartelera ===
  Future<List<dynamic>> getNowPlayingMovies(String countrycode) async {
    // 1) Obtener lista de géneros y construir map id->name
    final genresUrl = Uri.parse(
      'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=es-MX',
    );
    final genresResp = await http.get(genresUrl);
    Map<int, String> genreMap = {};
    if (genresResp.statusCode == 200) {
      final gdata = jsonDecode(genresResp.body);
      final List gList = gdata['genres'] ?? [];
      for (var g in gList) {
        genreMap[g['id'] as int] = g['name'] as String;
      }
    }

    // 2) Obtener now_playing
    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/now_playing?api_key=$apiKey&language=es-MX&region=$countrycode&page=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];

      // 3) Mapear genre_ids a nombres y añadir campo `genres`
      final List<Map<String, dynamic>> enriched = results
          .map<Map<String, dynamic>>((m) {
            final List ids = (m['genre_ids'] ?? []) as List;
            final List<String> names = ids
                .map<String>((id) => genreMap[id as int] ?? 'Desconocido')
                .toList();
            final Map<String, dynamic> copy = Map<String, dynamic>.from(
              m as Map,
            );
            copy['genres'] = names;
            return copy;
          })
          .toList();

      return enriched;
    } else {
      throw Exception('Error al obtener cartelera: ${response.statusCode}');
    }
  }

  // === 2. Detalles completos de una película ===
  Future<Map<String, dynamic>> getMovieFullDetails(int movieId) async {
    //final language = 'es-MX';

    String language =
        '${WidgetsBinding.instance.platformDispatcher.locale.languageCode}-${WidgetsBinding.instance.platformDispatcher.locale.countryCode!}';

    if (language != 'es-MX' && language != 'pt-BR') {
      language = 'es-MX';
    }

    final detailsUrl =
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=$language';
    final creditsUrl =
        'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey';
    final videosUrl =
        'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey&language=$language';

    try {
      final detailsResponse = await http.get(Uri.parse(detailsUrl));
      final creditsResponse = await http.get(Uri.parse(creditsUrl));
      final videosResponse = await http.get(Uri.parse(videosUrl));

      if (detailsResponse.statusCode == 200 &&
          creditsResponse.statusCode == 200) {
        final details = jsonDecode(detailsResponse.body);
        final credits = jsonDecode(creditsResponse.body);
        final videos = jsonDecode(videosResponse.body);

        final director =
            (credits['crew'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .firstWhere(
                  (c) => c['job'] == 'Director',
                  orElse: () => {'name': 'Desconocido'},
                )['name'] ??
            'Desconocido';

        final castList = (credits['cast'] as List<dynamic>?) ?? [];
        final castNames = castList
            .take(3)
            .map((actor) => actor['name'] ?? '')
            .toList()
            .join(', ');

        final trailer = (videos['results'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
            .firstWhere(
              (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
              orElse: () => {'key': null},
            )['key'];

        return {
          'id': movieId,
          'title': details['title'],
          'original_title': details['original_title'],
          'release_date': details['release_date'],
          'poster_path': details['poster_path'],
          'overview': details['overview'],
          'director': director,
          'cast': castNames,
          'trailer_key': trailer,
        };
      }
    } catch (e) {
      print('Error obteniendo detalles de película: $e');
    }

    return {};
  }

  Future<String?> getMovieTrailer(int movieId) async {
    final url =
        'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey&language=es-MX';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener el trailer');
    }

    final data = jsonDecode(response.body);
    final List results = data['results'] ?? [];

    // Buscar un trailer de YouTube
    final trailer = results.firstWhere(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
      orElse: () => {},
    );

    if (trailer.isNotEmpty) {
      return trailer['key']; // clave del video de YouTube
    }
    return null;
  }
}
