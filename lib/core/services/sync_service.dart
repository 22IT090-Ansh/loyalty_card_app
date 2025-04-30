import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:loyalty_card_app/core/constants/app_constants.dart';
import 'package:loyalty_card_app/core/services/local_storage_service.dart';
import 'package:loyalty_card_app/shared/models/loyalty_card.dart';

class SyncService {
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<void> syncData() async {
    if (!await isConnected()) {
      throw Exception(AppConstants.noInternetError);
    }

    try {
      final localCards = LocalStorageService.getAllCards();
      final unsyncedCards = localCards.where((card) => !card.isSynced).toList();

      for (final card in unsyncedCards) {
        await _syncCard(card);
      }
    } catch (e) {
      throw Exception(AppConstants.syncError);
    }
  }

  static Future<void> _syncCard(LoyaltyCard card) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.cardsEndpoint}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: card.toJson(),
      );

      if (response.statusCode == 200) {
        final syncedCard = card.copyWith(isSynced: true);
        await LocalStorageService.updateCard(syncedCard);
      } else {
        throw Exception('Failed to sync card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to sync card: $e');
    }
  }

  static Future<void> fetchRemoteChanges() async {
    if (!await isConnected()) {
      throw Exception(AppConstants.noInternetError);
    }

    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.syncEndpoint}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse response and update local storage
        // Implementation depends on your API response format
      } else {
        throw Exception('Failed to fetch remote changes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch remote changes: $e');
    }
  }
} 