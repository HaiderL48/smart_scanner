import 'dart:developer';
import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrServices {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> extractTextFromFile(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);

      return await _processImage(inputImage);
    } catch (error) {
      throw Exception('Failed to read image: $error');
    }
  }

  Future<String> extractTextFromPath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      return await _processImage(inputImage);
    } catch (error) {
      throw Exception('Failed to read image: $error');
    }
  }

  Future<String> _processImage(InputImage inputImage) async {
    try {
      final RecognizedText recognizedText = await _recognizer.processImage(
        inputImage,
      );
      log('Recognized Text: ${recognizedText.text}');

      String fullText = recognizedText.blocks
          .map((block) => block.text)
          .join('\n');

      return fullText;
    } catch (error) {
      throw Exception('Failed to process image: $error');
    }
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
