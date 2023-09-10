import UIKit
import Flutter
import GoogleMaps
import workmanager
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA508-nUFqun1Xu5SVTpTaLrVFHuIt8cXA")
    
    FirebaseApp.configure() //add this before the code below
    WorkmanagerPlugin.registerTask(withIdentifier: "task-identifier")
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))


    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
