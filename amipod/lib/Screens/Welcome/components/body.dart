import 'package:dipity/RegistrationScreens/registration.dart';
import 'package:dipity/Screens/Login/login_screen.dart';
import 'package:dipity/Services/notifications_api.dart';
import 'package:dipity/StateManagement/connections_contacts_model.dart';
import 'package:dipity/constants.dart';
import 'package:flutter/material.dart';
import 'package:dipity/Screens/Welcome/components/background.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatelessWidget {
  void navigateUser(BuildContext context) async {
    print('are we navigating?');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    // FlutterSecureStorage storage = FlutterSecureStorage();
    // await storage.deleteAll();

    // NotificationApi notificationManager = NotificationApi();

    // notificationManager.testNotification();

    Workmanager().registerOneOffTask(
      "task-identifier",
      "simpleTask",
      initialDelay: Duration(seconds: 20),
    );

    var status = prefs.getBool(loggedInKey) ?? false;
    if (status) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const RegistrationPages()));
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ConnectionsContactsModel>(context, listen: false).setAllBoxes();
    Size size =
        MediaQuery.of(context).size; //provides total height and width of screen
    return Background(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: SvgPicture.asset(
              'assets/images/dipity.svg',
              width: 180,
              height: 180,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 0.0, left: 0.0),
            child: Text("Reconnect.\nStay Connected.",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 40)),
          ),
          const SizedBox(height: 150),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () {
                navigateUser(context);
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          )
        ]));
  }
}
