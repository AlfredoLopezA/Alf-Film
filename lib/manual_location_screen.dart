import 'package:flutter/material.dart';
import 'background_wrapper.dart';

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
      debugPrint('País detectado automáticamente: $matchedCountry');

      if (matchedCountry != null && countries.contains(matchedCountry)) {
        setState(() {
          selectedCountry = matchedCountry;
          countryDetected = true;
        });

        // Da foco al campo ciudad después de un breve delay
        Future.delayed(const Duration(milliseconds: 300), () {
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white70,
                  labelText: 'Ingresa tu ciudad',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (selectedCountry != null &&
                      cityController.text.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/movies',
                      arguments: {
                        'country': selectedCountry,
                        'city': cityController.text.trim(),
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Por favor completa todos los campos'),
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
    );
  }
}
