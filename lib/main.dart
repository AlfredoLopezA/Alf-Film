import 'package:alf_film/LocationConfirmationScreen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'splash_screen.dart';
import 'BackgroundWrapper.dart';

void main() {
  runApp(AlfFilmApp());
}

class AlfFilmApp extends StatelessWidget {
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
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
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
        _locationMessage = 'Lat: ${pos.latitude}, Lon: ${pos.longitude}';
      });

      // Aquí podrías usar reverse geocoding para obtener ciudad/comuna
      Navigator.pushNamed(context, '/confirm', arguments: pos);
    } else {
      setState(() {
        _locationMessage = 'No se pudo obtener la ubicación.';
      });
      // Aquí podrías redirigir a selección manual de país/ciudad
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
