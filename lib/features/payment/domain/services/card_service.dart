import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/payment_card.dart';

class CardService {
  static const String _cardsKey = 'saved_payment_cards';
  final Uuid _uuid = const Uuid();

  // Get all saved cards
  Future<List<PaymentCard>> getSavedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString(_cardsKey);
    
    if (cardsJson == null || cardsJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(cardsJson);
    return decoded.map((item) => _cardFromJson(item)).toList();
  }
  
  // Save a new card
  Future<bool> saveCard(PaymentCard card) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<PaymentCard> existingCards = await getSavedCards();
      
      // If this is the first card or isDefault is true, make it default
      final bool shouldBeDefault = existingCards.isEmpty || card.isDefault;
      
      // If this card should be default, make sure others are not
      final List<PaymentCard> updatedCards = shouldBeDefault
          ? existingCards.map((c) => c.copyWith(isDefault: false)).toList()
          : List.from(existingCards);
      
      // Add new card with a generated ID if needed
      final cardWithId = card.id.isEmpty 
          ? card.copyWith(id: _uuid.v4(), isDefault: shouldBeDefault)
          : card.copyWith(isDefault: shouldBeDefault);
      
      updatedCards.add(cardWithId);
      
      // Save to preferences
      final String encoded = jsonEncode(updatedCards.map(_cardToJson).toList());
      return await prefs.setString(_cardsKey, encoded);
    } catch (e) {
      print('Error saving card: $e');
      return false;
    }
  }
  
  // Delete a saved card
  Future<bool> deleteCard(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<PaymentCard> existingCards = await getSavedCards();
      
      // Remove the card with matching ID
      final List<PaymentCard> updatedCards = existingCards
          .where((card) => card.id != cardId)
          .toList();
      
      // If we deleted the default card, make the first one default (if any left)
      if (existingCards.any((c) => c.id == cardId && c.isDefault) && 
          updatedCards.isNotEmpty) {
        updatedCards[0] = updatedCards[0].copyWith(isDefault: true);
      }
      
      // Save to preferences
      final String encoded = jsonEncode(updatedCards.map(_cardToJson).toList());
      return await prefs.setString(_cardsKey, encoded);
    } catch (e) {
      print('Error deleting card: $e');
      return false;
    }
  }
  
  // Set a card as default
  Future<bool> setDefaultCard(String cardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<PaymentCard> existingCards = await getSavedCards();
      
      // Update all cards
      final List<PaymentCard> updatedCards = existingCards.map((card) {
        return card.copyWith(isDefault: card.id == cardId);
      }).toList();
      
      // Save to preferences
      final String encoded = jsonEncode(updatedCards.map(_cardToJson).toList());
      return await prefs.setString(_cardsKey, encoded);
    } catch (e) {
      print('Error setting default card: $e');
      return false;
    }
  }
  
  // Convert a card to JSON
  Map<String, dynamic> _cardToJson(PaymentCard card) {
    return {
      'id': card.id,
      'cardNumber': card.cardNumber,
      'expiryDate': card.expiryDate,
      'cardHolderName': card.cardHolderName,
      'cvvCode': card.cvvCode,
      'isDefault': card.isDefault,
    };
  }
  
  // Convert JSON to card
  PaymentCard _cardFromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
      cvvCode: json['cvvCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
} 