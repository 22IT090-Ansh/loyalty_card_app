import 'package:flutter/material.dart';
import 'package:loyalty_card_app/core/models/loyalty_card.dart';
import 'package:loyalty_card_app/core/services/local_storage_service.dart';
import 'package:loyalty_card_app/core/services/barcode_service.dart';
import 'package:loyalty_card_app/features/card_management/screens/scan_card_screen.dart';
import 'package:uuid/uuid.dart';

class AddCardScreen extends StatefulWidget {
  final String? scannedBarcode;

  const AddCardScreen({super.key, this.scannedBarcode});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expiryDate;
  String? _barcode;

  @override
  void initState() {
    super.initState();
    if (widget.scannedBarcode != null) {
      _barcode = widget.scannedBarcode;
      _cardNumberController.text = widget.scannedBarcode!;
    }
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      final card = LoyaltyCard(
        id: const Uuid().v4(),
        name: _nameController.text,
        cardNumber: _cardNumberController.text,
        barcode: _barcode,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        expiryDate: _expiryDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await LocalStorageService.addCard(card);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _scanBarcode() async {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const ScanCardScreen()),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Card Name',
                hintText: 'Enter the name of the loyalty card',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a card name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      hintText: 'Enter the card number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a card number';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                  tooltip: 'Scan Barcode',
                ),
              ],
            ),
            if (_barcode != null) ...[
              const SizedBox(height: 16),
              Center(
                child: BarcodeService.generateBarcodeWidget(_barcode!),
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expiry Date'),
              subtitle: Text(_expiryDate == null
                  ? 'No date selected'
                  : 'Expires on: ${_expiryDate.toString().split(' ')[0]}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveCard,
        child: const Icon(Icons.save),
      ),
    );
  }
} 