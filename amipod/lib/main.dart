import 'dart:async';

import 'package:dipity/Screens/Login/login_screen.dart';
import 'package:dipity/Services/notifications_api.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Screens/Welcome/welcome_screen.dart';
import 'package:dipity/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'HiveModels/connection_model.dart';
import 'HiveModels/contact_model.dart';
import 'HiveModels/pod_model.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive DB
  await Hive.initFlutter();
  Hive.registerAdapter(ContactModelAdapter());
  Hive.registerAdapter(ConnectionModelAdapter());
  Hive.registerAdapter(PodModelAdapter());

  // Initialize Firebase

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher);

  runApp(MyApp());
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    try {
      print(task);
      // initialise the plugin of flutterlocalnotifications.
      NotificationApi notificationManager = NotificationApi();

      print('we executed a background task: ');
      print('was it ios: ${Workmanager.iOSBackgroundTask}');
      notificationManager.testNotification();
    } catch (err) {
      print('FAILED THE TASKE');
      print(err);
    }

    // switch (task) {
    //   case Workmanager.iOSBackgroundTask:
    //     print("The iOS background fetch was triggered");

    //     notificationManager.testNotification();

    //     // NotificationManager.createNewNotification(
    //     //     'Checking for Connections'); // calls your control code
    //     break;

    //   // case NotificationManager.checkDistance:
    //   //   NotificationManager.createNewNotification('Checking for distance');
    // }
    return Future.value(true);
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/dipity-1024.png"),
              fit: BoxFit.cover),
        ),
      ),
    );
  }

  void startTimer() {
    Timer(Duration(seconds: 1), () {
      navigateUser(); //It will redirect  after 3 seconds
    });
  }

  void navigateUser() async {
    print('are we navigating?');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    // FlutterSecureStorage storage = FlutterSecureStorage();
    // await storage.deleteAll();

    Provider.of<ConnectionsContactsModel>(context, listen: false).setAllBoxes();

    var status = prefs.getBool(loggedInKey) ?? false;
    if (status) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    print('START THIS APP UP BOI');

    // NotificationManager.startListeningNotificationEvents();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ConnectionsContactsModel>(
              create: (context) => ConnectionsContactsModel()),
        ],
        child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: MaterialApp(
              title: 'Dipity',
              theme: ThemeData(
                  primaryColor: primaryColor,
                  scaffoldBackgroundColor: backgroundColor),
              home: WelcomeScreen(),
            )));
  }
}
