import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
// ignore: depend_on_referenced_packages
import 'package:geocoding/geocoding.dart';
import 'background_wrapper.dart';

class LocationConfirmationScreen extends StatelessWidget {
  const LocationConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Position? position =
        ModalRoute.of(context)?.settings.arguments as Position?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Ubicación'),
        automaticallyImplyLeading: false,
      ),
      body: BackgroundWrapper(
        child: Center(
          child: position == null
              ? Text(
                  'No se recibió ubicación.',
                  style: TextStyle(color: Colors.white),
                )
              : FutureBuilder<Map<String, String>>(
                  future: getLocationFromPosition(position),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    final locationData =
                        snapshot.data ??
                        {
                          'city': 'desconocida',
                          'country': 'desconocido',
                          'countrycode': 'desconocido',
                        };
                    final city = locationData['city']!;
                    final country = locationData['country']!;
                    final countrycode = locationData['countrycode']!;
                    return Column(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // <- Posición superior
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // <- Centrado
                      children: [
                        Text(
                          '¿Estás en esta ubicación?',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          city,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          country,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/movies',
                              arguments: {
                                'country': country,
                                'city': city,
                                'countrycode': countrycode,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo,
                          ),
                          child: Text(
                            'Sí, continuar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/manual',
                              arguments: {'country': country, 'city': city},
                            );
                          },
                          child: Text(
                            'No, seleccionar manualmente',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

Future<Map<String, String>> getLocationFromPosition(Position position) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );
  if (placemarks.isNotEmpty) {
    final placemark = placemarks.first;
    return {
      'city': placemark.locality ?? 'Desconocida',
      'country': placemark.country ?? 'Desconocido',
      'countrycode': placemark.isoCountryCode ?? 'Desconocido',
    };
  }
  return {
    'city': 'Desconocida',
    'country': 'Desconocido',
    'countrycode': 'Desconocido',
  };
}

/*
Future<String> getCityFromPosition(Position position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      return '${place.locality}, ${place.country}';
    }
  } catch (e) {
    debugPrint('Error al obtener ciudad: $e');
  }
  return 'Ubicación desconocida';
}
*/
