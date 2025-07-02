// // lib/data/services/notification_service.dart
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../core/constants/storage_keys.dart';
// import '../../core/constants/api_constants.dart';
// import '../../core/errors/app_exception.dart';
// import '../models/notifications/notification_model.dart';
// import '../repositories/notifications_repository.dart';
// import 'storage_service.dart';
// import 'device_service.dart';

// final notificationServiceProvider = Provider<NotificationService>((ref) {
//   return NotificationService(ref.read(notificationsRepositoryProvider));
// });

// /// Notification service that handles Firebase Cloud Messaging (FCM),
// /// local notifications, and push notification management
// class NotificationService {
//   final NotificationsRepository _notificationsRepository;

//   // Firebase Messaging instance
//   static FirebaseMessaging? _firebaseMessaging;

//   // Local notifications plugin
//   static FlutterLocalNotificationsPlugin? _localNotifications;

//   // Stream controllers for notification events
//   final _notificationController =
//       StreamController<NotificationModel>.broadcast();
//   final _tokenController = StreamController<String>.broadcast();

//   // Current FCM token
//   String? _currentToken;

//   // Initialization flag
//   static bool _isInitialized = false;

//   NotificationService(this._notificationsRepository);

//   // ===== GETTERS =====

//   /// Stream of incoming notifications
//   Stream<NotificationModel> get notificationStream =>
//       _notificationController.stream;

//   /// Stream of FCM token updates
//   Stream<String> get tokenStream => _tokenController.stream;

//   /// Current FCM token
//   String? get currentToken => _currentToken;

//   /// Check if notifications are initialized
//   static bool get isInitialized => _isInitialized;

//   // ===== INITIALIZATION =====

//   /// Initialize notification service
//   static Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       // Initialize Firebase Messaging
//       _firebaseMessaging = FirebaseMessaging.instance;

//       // Initialize local notifications
//       _localNotifications = FlutterLocalNotificationsPlugin();

//       // Request permissions
//       await _requestPermissions();

//       // Initialize local notifications
//       await _initializeLocalNotifications();

//       // Set up message handlers
//       await _setupMessageHandlers();

//       _isInitialized = true;

//       if (kDebugMode) {
//         print('NotificationService: Initialized successfully');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('NotificationService: Initialization failed: $e');
//       }
//       rethrow;
//     }
//   }

//   // ===== FCM TOKEN MANAGEMENT =====

//   /// Register FCM token with server
//   static Future<void> registerFcmToken() async {
//     try {
//       if (!_isInitialized) {
//         throw AppException.deviceError('NotificationService not initialized');
//       }

//       final token = await _firebaseMessaging!.getToken();
//       if (token == null) {
//         throw AppException.deviceError('Failed to get FCM token');
//       }

//       // Store token locally
//       await StorageService.setString(StorageKeys.fcmToken, token);

//       // Check if already registered
//       final lastRegisteredToken = await StorageService.getString(
//         'last_registered_fcm_token',
//       );
//       if (lastRegisteredToken == token) {
//         return; // Already registered
//       }

//       // Prepare device info for registration
//       final deviceId = await DeviceService.getDeviceId();
//       final deviceInfo = await DeviceService.getFullDeviceInfo();

//       final request = FCMTokenRequest(
//         fcmToken: token,
//         deviceId: deviceId,
//         platform: Platform.isAndroid ? 'android' : 'ios',
//         appVersion: deviceInfo['appVersion'] as String?,
//         osVersion: deviceInfo['osVersion'] as String?,
//         deviceModel: deviceInfo['model'] as String?,
//         deviceBrand: deviceInfo['brand'] as String?,
//       );

//       // Register with server via repository
//       final notificationsRepo = ProviderContainer().read(
//         notificationsRepositoryProvider,
//       );
//       await notificationsRepo.registerDeviceToken(request);

//       // Mark as registered
//       await StorageService.setString('last_registered_fcm_token', token);
//       await StorageService.setBool(StorageKeys.fcmTokenRegistered, true);

//       if (kDebugMode) {
//         print('FCM token registered successfully: $token');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to register FCM token: $e');
//       }
//       throw AppException.deviceError('Failed to register FCM token: $e');
//     }
//   }

//   /// Unregister FCM token from server
//   static Future<void> unregisterFcmToken() async {
//     try {
//       if (!_isInitialized) return;

//       // Unregister from server
//       final notificationsRepo = ProviderContainer().read(
//         notificationsRepositoryProvider,
//       );
//       await notificationsRepo.unregisterDeviceToken();

//       // Clear local storage
//       await StorageService.setString(StorageKeys.fcmToken, '');
//       await StorageService.setString('last_registered_fcm_token', '');
//       await StorageService.setBool(StorageKeys.fcmTokenRegistered, false);

//       if (kDebugMode) {
//         print('FCM token unregistered successfully');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to unregister FCM token: $e');
//       }
//       // Don't throw error for unregister failure
//     }
//   }

//   /// Get current FCM token
//   Future<String?> getFcmToken() async {
//     try {
//       if (!_isInitialized) return null;

//       _currentToken = await _firebaseMessaging!.getToken();
//       return _currentToken;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to get FCM token: $e');
//       }
//       return null;
//     }
//   }

//   /// Refresh FCM token
//   Future<void> refreshFcmToken() async {
//     try {
//       if (!_isInitialized) return;

//       await _firebaseMessaging!.deleteToken();
//       await registerFcmToken();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to refresh FCM token: $e');
//       }
//     }
//   }

//   // ===== LOCAL NOTIFICATIONS =====

//   /// Show local notification
//   static Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//     NotificationDetails? notificationDetails,
//   }) async {
//     try {
//       if (!_isInitialized || _localNotifications == null) return;

//       final details =
//           notificationDetails ??
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'default_channel',
//               'Default',
//               channelDescription: 'Default notification channel',
//               importance: Importance.high,
//               priority: Priority.high,
//               showWhen: true,
//             ),
//             iOS: DarwinNotificationDetails(
//               presentAlert: true,
//               presentBadge: true,
//               presentSound: true,
//             ),
//           );

//       await _localNotifications!.show(
//         id,
//         title,
//         body,
//         details,
//         payload: payload,
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to show local notification: $e');
//       }
//     }
//   }

//   /// Cancel notification
//   static Future<void> cancelNotification(int id) async {
//     try {
//       if (!_isInitialized || _localNotifications == null) return;
//       await _localNotifications!.cancel(id);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to cancel notification: $e');
//       }
//     }
//   }

//   /// Cancel all notifications
//   static Future<void> cancelAllNotifications() async {
//     try {
//       if (!_isInitialized || _localNotifications == null) return;
//       await _localNotifications!.cancelAll();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to cancel all notifications: $e');
//       }
//     }
//   }

//   // ===== PERMISSION MANAGEMENT =====

//   /// Check notification permission status
//   static Future<bool> areNotificationsEnabled() async {
//     try {
//       if (!_isInitialized) return false;

//       final settings = await _firebaseMessaging!.getNotificationSettings();
//       return settings.authorizationStatus == AuthorizationStatus.authorized;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Request notification permissions
//   static Future<bool> requestPermissions() async {
//     try {
//       if (!_isInitialized) return false;

//       final settings = await _firebaseMessaging!.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );

//       final isAuthorized =
//           settings.authorizationStatus == AuthorizationStatus.authorized;

//       // Store permission status
//       await StorageService.setBool(
//         StorageKeys.pushNotificationsEnabled,
//         isAuthorized,
//       );

//       return isAuthorized;
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to request notification permissions: $e');
//       }
//       return false;
//     }
//   }

//   // ===== NOTIFICATION SETTINGS =====

//   /// Update notification preferences
//   Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
//     try {
//       await _notificationsRepository.updateNotificationSettings(settings);

//       // Update local storage
//       for (final entry in settings.entries) {
//         await StorageService.setBool(entry.key, entry.value as bool);
//       }
//     } catch (e) {
//       throw AppException.serverError(
//         'Failed to update notification settings: $e',
//       );
//     }
//   }

//   /// Get notification settings
//   Future<Map<String, dynamic>> getNotificationSettings() async {
//     try {
//       final response = await _notificationsRepository.getNotificationSettings();
//       return response.data ?? {};
//     } catch (e) {
//       throw AppException.serverError('Failed to get notification settings: $e');
//     }
//   }

//   // ===== PRIVATE METHODS =====

//   /// Request notification permissions
//   static Future<void> _requestPermissions() async {
//     await requestPermissions();
//   }

//   /// Initialize local notifications
//   static Future<void> _initializeLocalNotifications() async {
//     if (_localNotifications == null) return;

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _localNotifications!.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationResponse,
//     );

//     // Create notification channels for Android
//     if (Platform.isAndroid) {
//       await _createNotificationChannels();
//     }
//   }

//   /// Create notification channels for Android
//   static Future<void> _createNotificationChannels() async {
//     if (_localNotifications == null) return;

//     const defaultChannel = AndroidNotificationChannel(
//       'default_channel',
//       'Default',
//       description: 'Default notification channel',
//       importance: Importance.high,
//     );

//     const transactionChannel = AndroidNotificationChannel(
//       'transaction_channel',
//       'Transactions',
//       description: 'Transaction notifications',
//       importance: Importance.high,
//     );

//     const securityChannel = AndroidNotificationChannel(
//       'security_channel',
//       'Security',
//       description: 'Security notifications',
//       importance: Importance.max,
//     );

//     await _localNotifications!
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(defaultChannel);

//     await _localNotifications!
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(transactionChannel);

//     await _localNotifications!
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(securityChannel);
//   }

//   /// Set up FCM message handlers
//   static Future<void> _setupMessageHandlers() async {
//     if (_firebaseMessaging == null) return;

//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // Handle notification opened from terminated state
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

//     // Handle token refresh
//     _firebaseMessaging!.onTokenRefresh.listen((token) async {
//       await StorageService.setString(StorageKeys.fcmToken, token);
//       // Re-register with server
//       await registerFcmToken();
//     });
//   }

//   /// Handle background FCM messages
//   static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
//     if (kDebugMode) {
//       print('Background message received: ${message.messageId}');
//     }

//     // Process background message
//     await _processRemoteMessage(message);
//   }

//   /// Handle foreground FCM messages
//   static Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     if (kDebugMode) {
//       print('Foreground message received: ${message.messageId}');
//     }

//     // Show local notification for foreground messages
//     final notification = message.notification;
//     if (notification != null) {
//       await showLocalNotification(
//         id: message.hashCode,
//         title: notification.title ?? 'Notification',
//         body: notification.body ?? '',
//         payload: message.data.toString(),
//       );
//     }

//     // Process message
//     await _processRemoteMessage(message);
//   }

//   /// Handle notification opened
//   static Future<void> _handleNotificationOpened(RemoteMessage message) async {
//     if (kDebugMode) {
//       print('Notification opened: ${message.messageId}');
//     }

//     // Handle notification tap
//     await _processRemoteMessage(message, opened: true);
//   }

//   /// Process remote message
//   static Future<void> _processRemoteMessage(
//     RemoteMessage message, {
//     bool opened = false,
//   }) async {
//     try {
//       // Create notification model from message
//       final notificationModel = NotificationModel(
//         id:
//             message.messageId ??
//             DateTime.now().millisecondsSinceEpoch.toString(),
//         title: message.notification?.title ?? 'Notification',
//         message: message.notification?.body ?? '',
//         type: message.data['type'] ?? 'general',
//         read: false,
//         createdAt: DateTime.now(),
//         data: message.data,
//         imageUrl:
//             message.notification?.android?.imageUrl ??
//             message.notification?.apple?.imageUrl,
//         actionUrl: message.data['actionUrl'],
//       );

//       // Emit notification to stream
//       final container = ProviderContainer();
//       final service = container.read(notificationServiceProvider);
//       service._notificationController.add(notificationModel);

//       // Handle specific notification types
//       await _handleNotificationByType(notificationModel, opened: opened);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Failed to process remote message: $e');
//       }
//     }
//   }

//   /// Handle notification based on type
//   static Future<void> _handleNotificationByType(
//     NotificationModel notification, {
//     bool opened = false,
//   }) async {
//     switch (notification.type) {
//       case 'transaction':
//         // Handle transaction notification
//         break;
//       case 'security':
//         // Handle security notification
//         break;
//       case 'kyc':
//         // Handle KYC notification
//         break;
//       case 'loan':
//         // Handle loan notification
//         break;
//       case 'referral':
//         // Handle referral notification
//         break;
//       default:
//         // Handle general notification
//         break;
//     }
//   }

//   /// Handle local notification response
//   static void _onNotificationResponse(NotificationResponse response) {
//     if (kDebugMode) {
//       print('Local notification tapped: ${response.payload}');
//     }

//     // Handle notification tap
//     // You can navigate to specific screens based on payload
//   }

//   /// Dispose notification service
//   void dispose() {
//     _notificationController.close();
//     _tokenController.close();
//   }
// }
