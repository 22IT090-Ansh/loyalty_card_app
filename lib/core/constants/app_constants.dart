class AppConstants {
  // Hive box names
  static const String loyaltyCardsBox = 'loyalty_cards';
  static const String userBox = 'user_data';
  
  // Encryption keys
  static const String encryptionKey = 'your-32-character-encryption-key';
  
  // Notification channels
  static const String notificationChannelId = 'loyalty_card_notifications';
  static const String notificationChannelName = 'Loyalty Card Notifications';
  static const String notificationChannelDescription = 'Notifications for loyalty card updates and expiration alerts';
  
  // API endpoints
  static const String baseUrl = 'https://api.loyaltycards.com/v1';
  static const String cardsEndpoint = '/cards';
  static const String syncEndpoint = '/sync';
  
  // Cache durations
  static const int cacheDurationInMinutes = 60;
  
  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternetError = 'No internet connection. Some features may be limited.';
  static const String syncError = 'Failed to sync data. Please check your connection.';
  
  // Success messages
  static const String cardAddedSuccess = 'Card added successfully';
  static const String cardUpdatedSuccess = 'Card updated successfully';
  static const String syncSuccess = 'Data synced successfully';
} 