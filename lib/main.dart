import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loyalty_card_app/core/services/local_storage_service.dart';
import 'package:loyalty_card_app/core/services/notification_service.dart';
import 'package:loyalty_card_app/features/card_management/screens/card_list_screen.dart';
import 'package:loyalty_card_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await LocalStorageService.init();
  await NotificationService().initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loyalty Card App',
      theme: AppTheme.lightTheme,
      home: const CardListScreen(),
    );
  }
}
