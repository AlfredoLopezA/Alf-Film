import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/tmdb_service.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  final String countryCode;

  const MovieDetailsScreen({
    super.key,
    required this.movieId,
    required this.countryCode,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with AutomaticKeepAliveClientMixin {
  final TMDBService tmdbService = TMDBService();
  Map<String, dynamic>? movieDetails;
  bool isLoading = true;
  YoutubePlayerController? _youtubeController;

  @override
  bool get wantKeepAlive => true; // evita que se recargue al volver atrás

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final details = await tmdbService.getMovieFullDetails(widget.movieId);
      if (details['trailer_key'] != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: details['trailer_key'],
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: false,
          ),
        );
      }
      setState(() {
        movieDetails = details;
      });
    } catch (e) {
      debugPrint('Error cargando detalles: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Detalles de la Película'),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // vuelve sin recargar lista
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : movieDetails == null
          ? const Center(
              child: Text(
                'No se pudieron cargar los detalles.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Poster
                  if (movieDetails!['poster_path'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movieDetails!['poster_path']}',
                        height: 350,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    movieDetails!['title'] ?? 'Sin título',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '(${movieDetails!['original_title'] ?? 'Sin título original'})',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // Fecha
                  Text(
                    'Estreno: ${movieDetails!['release_date'] ?? 'N/D'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),

                  // Director
                  Text(
                    'Director: ${movieDetails!['director'] ?? 'Desconocido'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),

                  // Reparto
                  Text(
                    'Protagonistas: ${movieDetails!['cast'] ?? 'N/D'}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Sinopsis
                  Text(
                    movieDetails!['overview'] ?? 'Sin descripción disponible.',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 30),

                  // Tráiler
                  if (_youtubeController != null)
                    Column(
                      children: [
                        const Text(
                          'Tráiler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.red,
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
