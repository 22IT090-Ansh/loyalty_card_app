import 'package:flutter/material.dart';
import 'package:loyalty_card_app/core/services/local_storage_service.dart';
import 'package:loyalty_card_app/core/models/loyalty_card.dart';
import 'package:loyalty_card_app/features/card_management/screens/add_card_screen.dart';
import 'package:loyalty_card_app/features/card_management/screens/scan_card_screen.dart';
import 'package:loyalty_card_app/shared/widgets/card_item.dart';
import 'package:loyalty_card_app/core/services/barcode_service.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> with SingleTickerProviderStateMixin {
  List<LoyaltyCard> _cards = [];
  late AnimationController _animationController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<LoyaltyCard> _filteredCards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCards() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredCards = _cards;
      });
      return;
    }

    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _cards.where((card) =>
        card.name.toLowerCase().contains(query) ||
        card.description.toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _loadCards() async {
    final cards = LocalStorageService.getAllCards();
    setState(() {
      _cards = cards;
      _filteredCards = cards;
    });
  }

  Future<void> _addNewCard() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCardScreen(),
        fullscreenDialog: true,
      ),
    );
    
    if (result == true) {
      await _loadCards();
    }
  }

  Future<void> _scanCard() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanCardScreen(),
        fullscreenDialog: true,
      ),
    );
    
    if (result == true) {
      await _loadCards();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
    
    if (_isSearching) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(colorScheme),
            Expanded(
              child: _cards.isEmpty 
                ? _buildEmptyState() 
                : _buildCardsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'My Loyalty Cards',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.search_ellipsis,
                  progress: _animationController,
                  color: colorScheme.primary,
                ),
                onPressed: _toggleSearch,
                tooltip: 'Search cards',
              ),
              IconButton(
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: colorScheme.primary,
                ),
                onPressed: _scanCard,
                tooltip: 'Scan Card',
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearching ? 56 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search your cards...',
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No loyalty cards yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first card to start collecting rewards',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewCard,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Card'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList() {
    return _isSearching && _filteredCards.isEmpty
        ? _buildNoSearchResults()
        : RefreshIndicator(
            onRefresh: _loadCards,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _isSearching ? _filteredCards.length : _cards.length,
              itemBuilder: (context, index) {
                final card = _isSearching ? _filteredCards[index] : _cards[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCardItem(card),
                );
              },
            ),
          );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(LoyaltyCard card) {
    return Hero(
      tag: 'card_${card.id}',
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to card details with hero animation
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(card.name)),
                  body: Center(child: Text('Card Details')),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.card_membership,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (card.description.isNotEmpty)
                              Text(
                                card.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (card.points > 0)
                              Text(
                                '${card.points} points',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              card.points.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: card.barcode != null && card.barcode!.isNotEmpty
                                 ? BarcodeService.generateBarcodeWidget(
                                     card.barcode!,
                                     width: MediaQuery.of(context).size.width - 64,
                                     height: 70,
                                    )
                                 : const Icon(Icons.qr_code),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Implement full screen barcode view
                            },
                          ),
                          const Text(
                            'Scan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _addNewCard,
      icon: const Icon(Icons.add),
      label: const Text('Add Card'),
      elevation: 4,
    );
  }
}