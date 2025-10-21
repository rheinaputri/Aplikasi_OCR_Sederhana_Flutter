import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'result_screen.dart';

late List<CameraDescription> cameras;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 🔹 Inisialisasi kamera
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("Tidak ada kamera yang tersedia");
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

if (!mounted) return;
setState(() {});

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pemindaian Gagal! Periksa Izin Kamera atau coba lagi.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 🔹 OCR dari file gambar
  Future<String> _ocrFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  // 🔹 Ambil gambar dan proses OCR
  Future<void> _takePicture() async {
    try {
      if (_initializeControllerFuture == null) {
        throw Exception('Kamera belum mulai diinisialisasi');
      }

      await _initializeControllerFuture!;

      if (_controller == null || !_controller!.value.isInitialized) {
        throw Exception('Kamera belum siap');
      }

      final XFile image = await _controller!.takePicture();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memproses OCR, mohon tunggu...'),
          duration: Duration(seconds: 2),
        ),
      );

      final ocrText = await _ocrFromFile(File(image.path));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(ocrText: ocrText)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat mengambil atau memproses foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        // 🔹 Kondisi kamera belum siap
        if (_controller == null || !_controller!.value.isInitialized) {
          return Scaffold(
            backgroundColor: Colors.grey[900],
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(color: Colors.yellow),
                  SizedBox(height: 16),
                  Text(
                    'Memuat Kamera... Harap tunggu.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }

        // 🔹 Jika kamera sudah siap
        return Scaffold(
          appBar: AppBar(title: const Text('Kamera OCR')),
          body: Column(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera),
                  label: const Text('Ambil Foto & Scan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
