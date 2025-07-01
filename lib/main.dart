import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize services
  await AppConfig.initialize();
  await StorageService.initialize();
  await NotificationService.initialize();

  runApp(ProviderScope(child: IProfitApp()));
}
