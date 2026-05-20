import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_scanner/core/widgets/errors_widget.dart';
import 'package:smart_scanner/core/widgets/loader_widget.dart';
import 'package:smart_scanner/features/card_scanner/data/ocr_services.dart';
import 'package:smart_scanner/features/card_scanner/domain/card_details.dart';
import 'package:smart_scanner/features/card_scanner/domain/card_parser.dart';
import 'package:smart_scanner/features/card_scanner/presentation/widgets/card_details_widget.dart';
import 'package:smart_scanner/features/card_scanner/presentation/widgets/image_preview_widget.dart';
import 'package:smart_scanner/features/card_scanner/presentation/widgets/scan_button_widget.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen> {
  // Dependencies
  final OcrServices _ocrServices = OcrServices();
  final CardParser _cardParser = CardParser();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  File? _scannedImage;
  CardDetails? _cardDetails;
  bool _isLoading = false;
  String? _errorMessage;

  // dispose
  @override
  void dispose() {
    _ocrServices.dispose();
    super.dispose();
  }

  // Permissions
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Camera permission is required to scan the cards.';
      });
      return false;
    }
    return true;
  }

  // Scan from Camera
  Future<void> _scanFromCamera() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (photo != null) {
      await _processImage(File(photo.path));
    }
  }

  // Scan from gallery

  Future<void> _scanFromGallery() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (photo != null) {
      await _processImage(File(photo.path));
    }
  }

  // Process Image
  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      // _errorMessage = null;
      // _cardDetails = null;
      // _scannedImage = imageFile;
    });

    try {
      final rawText = await _ocrServices.extractTextFromFile(imageFile);
      // final cardDetails = _cardParser.parseCard(rawText);

      // image is too blurry or card is not visible properly
      if (rawText.trim().length < 20) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Image is too blurry or unclear. '
              'Make sure the card is flat, '
              'well-lit and fully visible.';
        });
        return;
      }
      final cardDetails = _cardParser.parseCard(rawText);

      // Duplicate check
      if (_cardDetails != null &&
          _cardDetails!.cardNumber != null &&
          _cardDetails!.cardNumber == cardDetails.cardNumber) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'This card has already been scanned.';
        });
        return; // stop here
      }
      setState(() {
        _cardDetails = cardDetails;
        _isLoading = false;

        if (cardDetails.isEmpty) {
          _errorMessage = _getErrorMessage(cardDetails);
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to process image: $error';
      });
    }
  }

  String _getErrorMessage(CardDetails details) {
    if (details.cardNumber == null && details.expiryDate == null) {
      return 'Could not read card. Make sure the card is '
          'flat, well-lit and fully visible.';
    }
    if (details.cardNumber == null) {
      return 'Card number not found. '
          'Try holding the camera steady.';
    }
    if (details.expiryDate == null) {
      return 'Expiry date not found. '
          'Make sure it is fully visible in the frame.';
    }
    return 'Scan incomplete. Please try again.';
  }

  void _reset() {
    setState(() {
      _scannedImage = null;
      _cardDetails = null;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Card Scanner'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        actions: [
          if (_scannedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Scan again',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Preview
            ImagePreviewWidget(scannedImage: _scannedImage),

            const SizedBox(height: 20),
            // Scan Button
            ScanButtonWidget(
              isLoading: _isLoading,
              scanFromCamera: _scanFromCamera,
              scanFromGallery: _scanFromGallery,
            ),
            const SizedBox(height: 20),
            if (_isLoading) LoaderWidget(),
            if (_errorMessage != null)
              ErrorsWidget(errorMessage: _errorMessage!),
            if (_cardDetails != null && !_cardDetails!.isEmpty)
              CardDetailsWidget(cardDetails: _cardDetails),
          ],
        ),
      ),
    );
  }
}
