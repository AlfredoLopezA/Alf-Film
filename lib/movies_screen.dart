import 'package:flutter/material.dart';
import 'package:alf_film/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'background_wrapper.dart';
import 'movie_details_screen.dart';
import '../services/tmdb_service.dart';

final String? apiKey = dotenv.env['TMDB_API_KEY'];

class MoviesScreen extends StatefulWidget {
  final String? country;
  final String? countrycode;
  final String? city;

  const MoviesScreen({super.key, this.country, this.city, this.countrycode});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String selectedGenre = 'Todos';
  final List<String> genres = [
    'Todos',
    'Acción',
    'Drama',
    'Comedia',
    'Terror',
    'Infantil',
    'Romance',
    'Ciencia ficción',
    'Documental',
  ];

  final TMDBService tmdbService = TMDBService();
  List<dynamic> movies = [];
  List<dynamic> allMovies = [];
  List<dynamic> filteredMovies = [];
  bool isLoading = true;
  String? country;
  String? countrycode;
  String? city;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtener los argumentos pasados a la ruta
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    city = args?['city'] ?? widget.city ?? 'Ciudad desconocida';
    country = args?['country'] ?? widget.country ?? 'País desconocido';
    countrycode =
        args?['countrycode'] ?? widget.countrycode ?? 'Código desconocido';

    // debugPrint('Código: $city, País: $country y código: $countrycode');
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      setState(() => isLoading = true);

      final data = await tmdbService.getNowPlayingMovies(countrycode!);
      setState(() {
        movies = data;
        allMovies = data;
        filteredMovies = List.from(allMovies);
      });
      /*
      final data = await tmdbService.getNowPlayingMovies(countrycode!);
      setState(() {
        movies = data;
      });
      */
    } catch (e) {
      debugPrint('Error al obtener cartelera: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('API Key: ${dotenv.env['TMDB_API_KEY']}');

    return Scaffold(
      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Cartelera en $city, $country',
                style: const TextStyle(fontSize: 22, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // ===== FILTRO POR GÉNERO =====
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrar por género',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: selectedGenre,
                          items: genres.map((genre) {
                            return DropdownMenuItem<String>(
                              value: genre,
                              child: Text(genre),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedGenre = value!;
                              if (selectedGenre == 'Todos') {
                                filteredMovies = List.from(allMovies);
                              } else {
                                filteredMovies = allMovies.where((movie) {
                                  final genres =
                                      movie['genres'] as List<dynamic>?;
                                  if (genres == null) return false;
                                  return genres.contains(selectedGenre);
                                }).toList();
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(),
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // ===== BOTÓN HOME =====
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.home,
                            color: Colors.white,
                            size: 48,
                          ),
                          onPressed: () {
                            hasVisitedHome = true;
                            Navigator.pushNamed(context, '/home');
                          },
                          tooltip: 'Ir al inicio',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // ===== LISTA DE PELÍCULAS =====
              Expanded(
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : movies.isEmpty
                      ? const Text(
                          'No se encontraron películas en cartelera.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        )
                      : ListView.builder(
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = filteredMovies[index];
                            final genres =
                                (movie['genres'] as List<dynamic>?)?.join(
                                  ', ',
                                ) ??
                                'N/D';
                            return Card(
                              color: const Color.fromRGBO(255, 255, 255, 0.9),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: movie['poster_path'] != null
                                    ? Image.network(
                                        'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.movie),
                                title: Text(movie['title'] ?? 'Sin título'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fecha: ${movie['release_date'] ?? 'N/D'}',
                                    ),
                                    if (genres.isNotEmpty)
                                      Text('Género: $genres'),
                                  ],
                                ),
                                // 👇 Acción al tocar una película
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => MovieDetailsScreen(
                                            movieId: movie['id'],
                                            countryCode: countrycode!,
                                          ),
                                      transitionsBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            final offsetAnimation =
                                                Tween<Offset>(
                                                  begin: const Offset(1.0, 0.0),
                                                  end: Offset.zero,
                                                ).animate(animation);
                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
