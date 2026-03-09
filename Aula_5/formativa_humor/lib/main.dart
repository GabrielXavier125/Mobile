import 'package:flutter/material.dart';

void main() {
  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Detector de Humor',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MoodScreen(),
    );
  }
}

class MoodScreen extends StatefulWidget {
  const MoodScreen({Key? key}) : super(key: key);

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String _currentMood = 'neutro';

  final Map<String, Map<String, dynamic>> moods = {
    'feliz': {
      'emoji': '😊',
      'texto': 'Feliz',
      'cor': Colors.yellow.shade400,
      'corTexto': Colors.amber.shade900,
    },
    'neutro': {
      'emoji': '😐',
      'texto': 'Neutro',
      'cor': Colors.grey.shade300,
      'corTexto': Colors.grey.shade800,
    },
    'bravo': {
      'emoji': '😠',
      'texto': 'Bravo',
      'cor': Colors.red.shade400,
      'corTexto': Colors.red.shade900,
    },
  };

  void _changeMood() {
    setState(() {
      final moodKeys = moods.keys.toList();
      final currentIndex = moodKeys.indexOf(_currentMood);
      final nextIndex = (currentIndex + 1) % moodKeys.length;
      _currentMood = moodKeys[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final moodData = moods[_currentMood]!;

    return Scaffold(
      backgroundColor: moodData['cor'],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji grande
            Text(moodData['emoji'], style: const TextStyle(fontSize: 120)),
            const SizedBox(height: 30),
            // Texto do humor
            Text(
              'Você está ${moodData['texto']}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: moodData['corTexto'],
              ),
            ),
            const SizedBox(height: 60),
            // Botão único para mudança de humor
            ElevatedButton(
              onPressed: _changeMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: const Text(
                'Mudar Humor',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
