import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:geolocator/geolocator.dart';

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
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationMessage = 'Ubicación no detectada';
  final TextEditingController _addressController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = 'Los servicios de ubicación están desactivados.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = 'Permiso de ubicación denegado.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = 'Permiso de ubicación denegado permanentemente.';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationMessage =
          'Lat: ${position.latitude}, Lon: ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cartelera Actual')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/mainscreen.png', fit: BoxFit.cover),
          SingleChildScrollView(
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
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Usar ubicación actual'),
                ),
                SizedBox(height: 10),
                Text(_locationMessage, style: TextStyle(color: Colors.white)),
                SizedBox(height: 30),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    labelText: 'O ingresa tu dirección',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    print('Dirección ingresada: $value');
                    // Aquí podrías usar geocoding para convertir dirección en coordenadas
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
