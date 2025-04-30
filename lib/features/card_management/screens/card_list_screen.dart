import 'package:flutter/material.dart';
import 'package:loyalty_card_app/core/services/local_storage_service.dart';
import 'package:loyalty_card_app/core/models/loyalty_card.dart';
import 'package:loyalty_card_app/features/card_management/screens/add_card_screen.dart';
import 'package:loyalty_card_app/features/card_management/screens/scan_card_screen.dart';
import 'package:loyalty_card_app/shared/widgets/card_item.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  List<LoyaltyCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = LocalStorageService.getAllCards();
    setState(() {
      _cards = cards;
    });
  }

  Future<void> _addNewCard() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );
    
    if (result == true) {
      await _loadCards();
    }
  }

  Future<void> _scanCard() async {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (context) => const ScanCardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Loyalty Cards'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanCard,
                tooltip: 'Scan Card',
              ),
            ],
          ),
          if (_cards.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No cards yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add your first loyalty card',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final card = _cards[index];
                    return CardItem(
                      card: card,
                      onTap: () {
                        // TODO: Navigate to card details
                      },
                    );
                  },
                  childCount: _cards.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCard,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }
} 