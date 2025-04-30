import 'package:mobile_scanner/mobile_scanner.dart' as scanner;
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcode;

class BarcodeService {
  static Widget generateBarcodeWidget(String data, {double? width, double? height}) {
    return barcode.BarcodeWidget(
      barcode: barcode.Barcode.code128(),
      data: data,
      width: width ?? 200,
      height: height ?? 80,
    );
  }

  static Widget generateQRWidget(String data, {double? width, double? height}) {
    return barcode.BarcodeWidget(
      barcode: barcode.Barcode.qrCode(),
      data: data,
      width: width ?? 200,
      height: height ?? 200,
    );
  }

  static Widget buildScannerWidget({
    required Function(String) onBarcodeDetected,
  }) {
    return scanner.MobileScanner(
      onDetect: (capture) {
        final List<scanner.Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          final String? code = barcode.rawValue;
          if (code != null) {
            onBarcodeDetected(code);
            break;
          }
        }
      },
    );
  }
} 