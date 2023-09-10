// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dipity/constants.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationsManager extends StatefulWidget {
//   @override
//   _NotificationsManagerState createState() => _NotificationsManagerState();
// }

// class _NotificationsManagerState extends State<NotificationsManager> {
//   FirebaseFirestore db = FirebaseFirestore.instance;

//   // 2. Instantiate Firebase Messaging
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   late FlutterLocalNotificationsPlugin fltNotification;

//   late NotificationSettings settings;

//   void pushFCMtoken() async {
//     String? token = await messaging.getToken();
//     print(token);
//   }

//   @override
//   void initState() {
//     super.initState();
//     pushFCMtoken();
//     registerNotifications();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Text('Flutter Push Notifiction'),
//       ),
//     );
//   }

//   Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     print("Handling a background message: ${message.messageId}");
//   }

//   void registerNotifications() async {
//     // 3. On iOS, this helps to take the user permissions
//     settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');

//       // initialise the plugin of flutterlocalnotifications.
//       // FlutterLocalNotificationsPlugin flip =
//       //     new FlutterLocalNotificationsPlugin();

//       FirebaseMessaging.onBackgroundMessage(
//           _firebaseMessagingBackgroundHandler);

//       // TODO: handle the received notifications

//       // For handling the received notifications
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         // Parse the message received
//         PushNotification notification = PushNotification(
//           title: message.notification?.title,
//           body: message.notification?.body,
//         );
//       });
//     } else {
//       print('User declined or has not accepted permission');
//     }
//   }

//   void onMessageOpen() {
//     //...

//     // For handling notification when the app is in background
//     // but not terminated
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       PushNotification notification = PushNotification(
//           title: message.notification?.title, body: message.notification?.body);
//       // setState(() {
//       //   _notificationInfo = notification;
//       //   _totalNotifications++;
//       // });
//     });
//   }

//   checkForInitialMessage() async {
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (initialMessage != null) {
//       PushNotification notification = PushNotification(
//         title: initialMessage.notification?.title,
//         body: initialMessage.notification?.body,
//       );
//       // setState(() {
//       //   _notificationInfo = notification;
//       //   _totalNotifications++;
//       // });
//     }
//   }
// }

// class PushNotification {
//   PushNotification({
//     this.title,
//     this.body,
//   });
//   String? title;
//   String? body;
// }
