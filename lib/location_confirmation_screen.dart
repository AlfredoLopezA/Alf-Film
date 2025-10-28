import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
              : FutureBuilder<String>(
                  future: getCityFromPosition(position),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    final city = snapshot.data ?? 'Ubicación desconocida';
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
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/movies');
                          },
                          child: Text('Sí, continuar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/manual');
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
