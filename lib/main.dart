import 'package:alf_film/location_confirmation_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'splash_screen.dart';
import 'background_wrapper.dart';
import 'manual_location_screen.dart';
import 'movies_screen.dart';

void main() {
  runApp(AlfFilmApp());
}

class AlfFilmApp extends StatelessWidget {
  const AlfFilmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alf-Film',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/confirm': (context) => LocationConfirmationScreen(),
        '/manual': (context) => ManualLocationScreen(), // pantalla manual
        '/movies': (context) => MoviesScreen(), // pantalla cartelera
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  String _locationMessage = 'Detectando ubicación...';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    Position? pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _locationMessage =
            'Ubicación detectada'; // 'Lat: ${pos.latitude}, Lon: ${pos.longitude}';
      });

      // Aquí podrías usar reverse geocoding para obtener ciudad/comuna
      Navigator.pushNamed(context, '/confirm', arguments: pos);
    } else {
      setState(() {
        _locationMessage = 'No se pudo obtener la ubicación.';
      });
      // Aquí podrías redirigir a selección manual de país/ciudad
      Navigator.pushNamed(context, '/manual', arguments: pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alf-Film'), automaticallyImplyLeading: false),
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Bienvenido a AlfFilm',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(_locationMessage, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
