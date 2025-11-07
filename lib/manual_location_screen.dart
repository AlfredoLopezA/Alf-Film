import 'package:flutter/material.dart';
import 'background_wrapper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:alf_film/main.dart';

class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({super.key});

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  final List<String> countries = [
    'Argentina',
    'Bolivia',
    'Brasil',
    'Chile',
    'Colombia',
    'Costa Rica',
    'Cuba',
    'Ecuador',
    'El Salvador',
    'Guatemala',
    'Honduras',
    'México',
    'Nicaragua',
    'Panamá',
    'Paraguay',
    'Perú',
    'Puerto Rico',
    'República Dominicana',
    'Uruguay',
    'Venezuela',
  ];

  String? selectedCountry;
  final TextEditingController cityController = TextEditingController();
  final FocusNode cityFocusNode = FocusNode();
  bool countryDetected = false;
  bool? cityValid;

  final Map<String, String> countryCodeMap = {
    'AR': 'Argentina',
    'BO': 'Bolivia',
    'BR': 'Brasil',
    'CL': 'Chile',
    'CO': 'Colombia',
    'CR': 'Costa Rica',
    'CU': 'Cuba',
    'EC': 'Ecuador',
    'SV': 'El Salvador',
    'GT': 'Guatemala',
    'HN': 'Honduras',
    'MX': 'México',
    'NI': 'Nicaragua',
    'PA': 'Panamá',
    'PY': 'Paraguay',
    'PE': 'Perú',
    'PR': 'Puerto Rico',
    'DO': 'República Dominicana',
    'UY': 'Uruguay',
    'VE': 'Venezuela',
  };

  String getCountryCode(String countryName) {
    return countryCodeMap.entries
        .firstWhere(
          (entry) => entry.value == countryName,
          orElse: () => const MapEntry('', ''),
        )
        .key
        .toLowerCase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCountryCode = Localizations.localeOf(context).countryCode;
    if (localeCountryCode != null) {
      final matchedCountry = countryCodeMap[localeCountryCode.toUpperCase()];

      if (matchedCountry != null && countries.contains(matchedCountry)) {
        setState(() {
          selectedCountry = matchedCountry;
          countryDetected = true;
        });

        // Da foco al campo ciudad después de un breve delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          FocusScope.of(context).requestFocus(cityFocusNode);
        });
      }
    }
  }

  @override
  void dispose() {
    cityController.dispose();
    cityFocusNode.dispose();
    super.dispose();
  }

  Future<bool> validateCityWithAPI(String city, String countryCode) async {
    try {
      final locations = await locationFromAddress('$city, $countryCode');

      if (locations.isEmpty) return false;

      final location = locations.first;
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) return false;

      final detectedCountryCode = placemarks.first.isoCountryCode
          ?.toLowerCase();
      return detectedCountryCode == countryCode.toLowerCase();
    } catch (e) {
      debugPrint('Error al validar ciudad: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                'Selecciona tu ubicación',
                style: TextStyle(fontSize: 22, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // Opción A: país detectado
              if (countryDetected) ...[
                Text(
                  'País detectado: $selectedCountry',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ] else ...[
                // Opción B: formulario normal
                DropdownButtonFormField<String>(
                  initialValue: selectedCountry,
                  hint: const Text('Selecciona un país'),
                  items: countries.map((country) {
                    final code = getCountryCode(country);
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Row(
                        children: [
                          Image.network(
                            'https://flagcdn.com/w40/$code.png',
                            width: 24,
                            height: 16,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(width: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(country),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                    });
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              SizedBox(height: 20),
              TextField(
                controller: cityController,
                focusNode: cityFocusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  labelText: 'Ingresa tu ciudad',
                  border: const OutlineInputBorder(),
                  suffixIcon: cityValid == null
                      ? null
                      : Icon(
                          cityValid! ? Icons.check_circle : Icons.error,
                          color: cityValid! ? Colors.green : Colors.red,
                        ),
                ),
                onChanged: (value) async {
                  final city = value.trim();
                  if (city.isEmpty || selectedCountry == null) {
                    setState(() => cityValid = null);
                    return;
                  }

                  final countryCode = getCountryCode(selectedCountry!);
                  final isValid = await validateCityWithAPI(city, countryCode);
                  setState(() => cityValid = isValid);
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final city = cityController.text.trim();
                  final country = selectedCountry;

                  if (country != null && city.isNotEmpty) {
                    final countryCode = getCountryCode(country);
                    final isValid = await validateCityWithAPI(
                      city,
                      countryCode,
                    );

                    if (isValid) {
                      Navigator.pushNamed(
                        context,
                        '/movies',
                        arguments: {
                          'country': country,
                          'city': city,
                          'countrycode': countryCode,
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'La ciudad ingresada no es del país seleccionado o el nombre es incorrecto.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  } else if (country == null && city.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.lightGreen,
                        content: const Row(
                          children: [
                            Icon(Icons.error_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Por favor selecciona el país e ingresa la ciudad.',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (country == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.lightGreen,
                        content: const Row(
                          children: [
                            Icon(Icons.error_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Por favor seleccione el país.',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.lightGreen,
                        content: const Row(
                          children: [
                            Icon(Icons.error_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Por favor ingresa la ciudad.',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: Text('Confirmar ubicación'),
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
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 48),
                onPressed: () {
                  hasVisitedHome = true;
                  Navigator.pushNamed(context, '/home');
                },
                tooltip: 'Ir al inicio',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
