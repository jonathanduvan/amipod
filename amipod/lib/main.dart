import 'dart:async';

import 'package:amipod/Screens/Login/login_screen.dart';
import 'package:amipod/StateManagement/connections_contacts_model.dart';
import 'package:flutter/material.dart';
import 'package:amipod/Screens/Welcome/welcome_screen.dart';
import 'package:amipod/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  // Initialize Hive DB
  await Hive.initFlutter();
  // Initialize Firebase

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class SplashScreen extends StatefulWidget {
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
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/andy.png"), fit: BoxFit.cover),
        ),
      ),
    );
  }

  void startTimer() {
    Timer(Duration(seconds: 3), () {
      navigateUser(); //It will redirect  after 3 seconds
    });
  }

  void navigateUser() async {
    // TEMPORARY CODE FOR RESTARTING LOGIN PROCESS
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.deleteAll();

    var status = prefs.getBool(LoggedInKey) ?? false;
    print(status);
    if (status) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()));
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // In this sample app, CatalogModel never changes, so a simple Provider
          // is sufficient.
          ChangeNotifierProvider<ConnectionsContactsModel>(
              create: (context) => ConnectionsContactsModel()),
        ],
        child: MaterialApp(
          title: 'Amipod',
          theme: ThemeData(
              primaryColor: primaryColor,
              scaffoldBackgroundColor: backgroundColor),
          home: SplashScreen(),
        ));
  }
}
