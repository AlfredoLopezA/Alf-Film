import 'package:alf_film/location_confirmation_screen.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'location_service.dart';
import 'splash_screen.dart';
import 'background_wrapper.dart';
import 'manual_location_screen.dart';
import 'movies_screen.dart';
import 'credits.dart';

bool hasVisitedHome = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const AlfFilmApp());
}

/*
void main() {
  runApp(AlfFilmApp());
}
*/

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
        '/credits': (context) => Credits(), // pantalla cartelera
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
  bool showDetectLocationButton = false;
  String _locationMessage = '';

  @override
  void initState() {
    super.initState();
    if (!hasVisitedHome) {
      _initLocation();
    }
  }

  Future<void> _initLocation() async {
    Position? pos = await _locationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _locationMessage =
            'Ubicación detectada...'; // 'Lat: ${pos.latitude}, Lon: ${pos.longitude}';
      });
      if (!mounted) return;
      Navigator.pushNamed(context, '/confirm', arguments: pos);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFE3F2FD), // celeste suave
            title: const Text(
              'Ubicación requerida',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            content: const Text(
              'La aplicación requiere que active su ubicación.\n¿Desea activarla ahora?',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                  setState(() {
                    showDetectLocationButton = true;
                  });
                },
                child: const Text('Sí', style: TextStyle(color: Colors.indigo)),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/manual');
                },
                child: const Text('No', style: TextStyle(color: Colors.indigo)),
              ),
            ],
          );
        },
      );
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
              if (showDetectLocationButton)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _initLocation();
                  },
                  child: const Text(
                    'Detectar ubicación',
                    style: TextStyle(color: Colors.indigo, fontSize: 16),
                  ),
                )
              else
                hasVisitedHome
                    ? FractionallySizedBox(
                        widthFactor: 0.4, // 👈 40% del ancho disponible
                        child: ElevatedButton(
                          onPressed: () {
                            // 🔁 Repite la lógica inicial de la app
                            _initLocation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text(
                            'Cartelera',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : Text(
                        _locationMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF16357A),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Este producto usa la API de TMDB pero no está respaldado ni certificado por TMDB.',
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/credits');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
              ),
              child: Text('  Créditos  ', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
