import 'package:flutter/material.dart';
import 'background_wrapper.dart';

class MoviesScreen extends StatelessWidget {
  final String? city;
  final String? country;

  const MoviesScreen({super.key, this.city, this.country});

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos si se pasaron desde la navegación
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String displayCity = args != null && args['city'] != null ? args['city'] : city ?? 'tu ciudad';
    final String? displayCountry = args != null ? args['country'] : country;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cartelera'),
        automaticallyImplyLeading: false,
      ),
      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Películas en cartelera en $displayCity',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (displayCountry != null)
                Text(
                  displayCountry,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Text(
                    'Aquí se mostrará la lista de películas próximamente.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
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
