import 'package:flutter/material.dart';
import 'background_base.dart';
import 'package:alf_film/main.dart';

class Credits extends StatefulWidget {
  const Credits({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreditsState createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Créditos'), automaticallyImplyLeading: false),
      body: BackgroundBase(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              Text(
                'Créditos',
                style: TextStyle(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(height: 30),
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
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Image.asset('assets/images/tmdb_logo.png', height: 16),
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
