import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loyalty_card_app/features/card_management/screens/add_card_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  MobileScannerController? controller;
  bool isStarted = false;
  bool isPermissionDenied = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInitialize();
  }

  Future<void> _checkPermissionAndInitialize() async {
    try {
      if (kIsWeb) {
        // Skip permission check on web and directly initialize camera
        await _initializeCamera();
      } else {
        final status = await Permission.camera.status;
        debugPrint('Camera permission status: $status');

        if (status.isGranted) {
          await _initializeCamera();
        } else {
          final result = await Permission.camera.request();
          debugPrint('Camera permission request result: $result');
          
          if (result.isGranted) {
            await _initializeCamera();
          } else {
            if (mounted) {
              setState(() {
                isPermissionDenied = true;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking permission: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to check camera permission: $e';
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('Initializing camera...');
      controller = MobileScannerController(
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.all],
      );
      
      if (kIsWeb) {
        // For web, we don't need to explicitly start the controller
        setState(() {
          isStarted = true;
        });
      } else {
        await controller?.start();
        debugPrint('Camera started successfully');
        
        if (mounted) {
          setState(() {
            isStarted = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          errorMessage = kIsWeb 
            ? 'Please make sure you\'ve allowed camera access in your browser settings.'
            : 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddCardScreen(scannedBarcode: code),
          ),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
        actions: [
          if (isStarted && controller != null && !kIsWeb)
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller!.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                  }
                },
              ),
              onPressed: () => controller?.toggleTorch(),
            ),
          if (controller != null && !kIsWeb)
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller!.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              onPressed: () => controller?.switchCamera(),
            ),
        ],
      ),
      body: errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Error',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkPermissionAndInitialize,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : isPermissionDenied
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.no_photography_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Permission Required',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Please grant camera permission to scan loyalty cards',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _openAppSettings,
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                )
              : isStarted && controller != null
                  ? Stack(
                      children: [
                        MobileScanner(
                          controller: controller!,
                          onDetect: _onDetect,
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ScannerOverlayPainter(),
                          ),
                        ),
                        const Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Text(
                            'Position the barcode within the frame',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    // Draw semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                scanAreaLeft,
                scanAreaTop,
                scanAreaSize,
                scanAreaSize,
              ),
              const Radius.circular(12),
            ),
          ),
      ),
      paint,
    );

    // Draw scanning area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          scanAreaLeft,
          scanAreaTop,
          scanAreaSize,
          scanAreaSize,
        ),
        const Radius.circular(12),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 