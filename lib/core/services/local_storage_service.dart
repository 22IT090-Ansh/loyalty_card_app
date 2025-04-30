import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loyalty_card_app/core/models/loyalty_card.dart';

class LocalStorageService {
  static const String _cardsKey = 'loyalty_cards';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<LoyaltyCard> getAllCards() {
    final String? cardsJson = _prefs?.getString(_cardsKey);
    if (cardsJson == null) return [];

    final List<dynamic> cardsList = json.decode(cardsJson);
    return cardsList.map((json) => LoyaltyCard.fromJson(json)).toList();
  }

  static Future<void> addCard(LoyaltyCard card) async {
    final cards = getAllCards();
    cards.add(card);
    await _saveCards(cards);
  }

  static Future<void> updateCard(LoyaltyCard updatedCard) async {
    final cards = getAllCards();
    final index = cards.indexWhere((card) => card.id == updatedCard.id);
    if (index != -1) {
      cards[index] = updatedCard;
      await _saveCards(cards);
    }
  }

  static Future<void> deleteCard(String cardId) async {
    final cards = getAllCards();
    cards.removeWhere((card) => card.id == cardId);
    await _saveCards(cards);
  }

  static Future<void> _saveCards(List<LoyaltyCard> cards) async {
    final String cardsJson = json.encode(cards.map((card) => card.toJson()).toList());
    await _prefs?.setString(_cardsKey, cardsJson);
  }
} 