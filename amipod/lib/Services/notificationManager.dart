// // import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:dipity/constants.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationManager {
//   static ReceivedAction? initialAction;
//   static const String checkConnections = 'checkConnections';
//   static const String checkDistance = 'checkDistance';

//   ///  *********************************************
//   ///     INITIALIZATIONS
//   ///  *********************************************

//   static Future<void> initializeLocalNotifications() async {
//     // await AwesomeNotifications().initialize(
//     //     null, //'resource://drawable/res_app_icon',//
//     //     [
//     //       NotificationChannel(
//     //           channelKey: 'alerts',
//     //           channelName: 'Alerts',
//     //           channelDescription: 'Notification tests as alerts',
//     //           groupAlertBehavior: GroupAlertBehavior.Children,
//     //           importance: NotificationImportance.High,
//     //           defaultPrivacy: NotificationPrivacy.Private,
//     //           defaultColor: primaryColor,
//     //           ledColor: primaryColor)
//     //     ],
//     //     debug: true);
//   }

//   static Future<void> startListeningNotificationEvents() async {
//     AwesomeNotifications().isNotificationAllowed().then((value) {
//       if (!value) {
//         try {
//           AwesomeNotifications().requestPermissionToSendNotifications().then(
//               (value) =>
//                   {AwesomeNotifications().actionStream.listen((event) {})});
//         } catch (error) {}
//       } else {
//         try {
//           AwesomeNotifications().actionStream.listen((event) {});
//         } catch (error) {}
//       }
//     });
//   }

//   Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     // If you're going to use other Firebase services in the background, such as Firestore,
//     // make sure you call `initializeApp` before using other Firebase services.
//     // await Firebase.initializeApp();
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: message.hashCode,
//         channelKey: "high_importance_channel",
//         title: message.data['title'],
//         body: message.data['body'],
//         bigPicture: message.data['image'],
//         notificationLayout: NotificationLayout.BigPicture,
//         largeIcon: message.data['image'],
//         payload: Map<String, String>.from(message.data),
//         hideLargeIconOnExpand: true,
//       ),
//     );
//   }

//   static Future<void> createNewNotification(String title) async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) {
//       await AwesomeNotifications().requestPermissionToSendNotifications();
//     }

//     try {
//       AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: -1, // -1 is replaced by a random number
//           channelKey: 'alerts',
//           title: title,
//           body: "We just checked for connections!!",
//           // bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
//           // largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
//           //'asset://assets/images/balloons-in-sky.jpg',
//           notificationLayout: NotificationLayout.BigPicture,
//           payload: {'notificationId': '1234567890'},
//         ),

//         // actionButtons: [
//         //   NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
//         //   NotificationActionButton(
//         //     key: 'REPLY',
//         //     label: 'Reply Message',
//         //   ),
//         //   NotificationActionButton(
//         //       key: 'DISMISS', label: 'Dismiss', isDangerousOption: true)
//         // ]
//       );
//     } catch (error) {
//       print('oh here');
//     }
//   }
// }
