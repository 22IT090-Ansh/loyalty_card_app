import 'package:flutter/material.dart';
import 'package:loyalty_card_app/core/services/barcode_service.dart';
import 'package:loyalty_card_app/features/card_management/screens/add_card_screen.dart';

class ScanCardScreen extends StatelessWidget {
  const ScanCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card'),
      ),
      body: BarcodeService.buildScannerWidget(
        onBarcodeDetected: (String barcode) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddCardScreen(scannedBarcode: barcode),
            ),
          );
        },
      ),
    );
  }
} 