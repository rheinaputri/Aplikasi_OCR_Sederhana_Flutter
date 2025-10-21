import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultScreen extends StatefulWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    // Set bahasa ke Bahasa Indonesia
    _flutterTts.setLanguage("id-ID");
    // Optional: atur rate/volume jika perlu
    // _flutterTts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    if (widget.ocrText.isEmpty) return;
    await _flutterTts.stop(); // hentikan jika ada yang sedang bicara
    await _flutterTts.speak(widget.ocrText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            widget.ocrText.isEmpty ? 'Tidak ada teks ditemukan.' : widget.ocrText,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      // Dua FAB: speak (volume) dan home
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol speak
          FloatingActionButton(
            heroTag: 'ttsSpeak',
            child: const Icon(Icons.volume_up),
            onPressed: _speak,
            tooltip: 'Bacakan Teks',
          ),
          const SizedBox(height: 12),
          // Tombol home (hapus semua route)
          FloatingActionButton(
            heroTag: 'goHome',
            child: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            tooltip: 'Kembali ke Home',
          ),
        ],
      ),
    );
  }
}
