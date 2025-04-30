import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loyalty_card_app/features/card_management/screens/add_card_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({Key? key}) : super(key: key);

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  bool _isPermissionGranted = false;
  bool _isInitialized = false;
  String? _errorMessage;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // For web, skip permission check and directly initialize camera
      if (kIsWeb) {
        _controller = MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
          formats: [BarcodeFormat.qrCode, BarcodeFormat.ean13],
        );
        setState(() {
          _isInitialized = true;
          _isPermissionGranted = true;
          _errorMessage = null;
        });
        return;
      }

      // For mobile platforms, check permissions
      final status = await Permission.camera.request();
      setState(() {
        _isPermissionGranted = status == PermissionStatus.granted;
      });

      if (_isPermissionGranted) {
        _controller = MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
          formats: [BarcodeFormat.qrCode, BarcodeFormat.ean13],
        );
        
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Camera permission is required to scan cards';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = kIsWeb 
          ? 'Please make sure you\'ve allowed camera access in your browser settings.'
          : 'Error initializing camera: \$e';
      });
      debugPrint('Camera initialization error: \$e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
        actions: [
          if (_isInitialized && _controller != null && !kIsWeb)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller?.toggleTorch(),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeCamera,
                    child: const Text('Try Again'),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Note: Make sure to allow camera access in your browser settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          }

          if (!_isInitialized || _controller == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            children: [
              MobileScanner(
                controller: _controller!,
                onDetect: (capture) {
                  debugPrint('Barcode detected!');
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    debugPrint('Barcode value: \${barcode.rawValue}');
                    if (barcode.rawValue != null) {
                      Navigator.pop(context, barcode.rawValue);
                      break;
                    }
                  }
                },
                errorBuilder: (context, error, child) {
                  debugPrint('Mobile scanner error: \$error');
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error: \$error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeCamera,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(40),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const Text(
                        'Position the barcode within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 