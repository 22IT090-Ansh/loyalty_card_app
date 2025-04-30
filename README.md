# Loyalty Card App

A modern Flutter application for managing loyalty cards digitally. This app helps users store and organize their loyalty cards in one place, eliminating the need to carry physical cards.

## Features

- 📸 Card Scanning: Scan physical loyalty cards using your device's camera
- 🎯 Manual Card Entry: Add cards manually with custom details
- 📱 Digital Display: Show barcodes for easy scanning at stores
- 🔔 Push Notifications: Get reminders about expiring points and special offers
- 💾 Offline Support: Access your cards without internet connection
- ☁️ Cloud Sync: Backup and sync cards across devices
- 🔒 Secure Storage: Keep your card data safe and encrypted

## Getting Started

### Prerequisites

- Flutter (latest version)
- Dart SDK
- Android Studio / VS Code
- iOS development setup (for iOS deployment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/22it090-Ansh/loyalty_card_app.git
```

2. Navigate to the project directory:
```bash
cd loyalty_card_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

### Web Setup

For running the app in web browsers:

1. Enable Flutter web support:
```bash
flutter config --enable-web
```

2. Run the web app:
```bash
flutter run -d chrome --web-renderer canvaskit
```

Note: Camera access requires HTTPS or localhost for web deployment.

## Project Structure

```
lib/
├── core/
│   ├── models/
│   └── services/
├── features/
│   └── card_management/
│       ├── screens/
│       └── widgets/
└── shared/
    └── widgets/
```

## Dependencies

- flutter_barcode_scanner: For scanning barcodes
- flutter_local_notifications: For local notifications
- shared_preferences: For local storage
- provider: For state management

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## Acknowledgments

- Flutter team for the amazing framework
- All contributors who participate in this project

## Support

For support, email 22it090@charusat.edu.in or create an issue in the repository.

## Screenshots

[Add screenshots of your app here]

