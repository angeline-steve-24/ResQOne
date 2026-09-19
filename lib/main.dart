import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'roadsos_protection',
    channelName: 'RoadSOS Protection',
    channelDescription:
        'Monitors for accidents while Protection Mode is active.',
    onlyAlertOnce: true,
  ),
  iosNotificationOptions: const IOSNotificationOptions(
    showNotification: false,
    playSound: false,
  ),
  foregroundTaskOptions: ForegroundTaskOptions(
    eventAction: ForegroundTaskEventAction.repeat(1000),
    autoRunOnBoot: false,
    autoRunOnMyPackageReplaced: true,
    allowWakeLock: true,
    allowWifiLock: true,
  ),
);
  FlutterForegroundTask.initCommunicationPort();

runApp(const RoadSOSApp());
}

class RoadSOSApp extends StatelessWidget {
  const RoadSOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'RoadSOS',

 theme: ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFD32F2F),
  ),

  scaffoldBackgroundColor:
      const Color(0xFFF5F5F5),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFD32F2F),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
  ),

  cardTheme: const CardThemeData(
    elevation: 6,
    shadowColor: Colors.black12,
  ),

  elevatedButtonTheme:
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xFFD32F2F),
      foregroundColor:
          Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),
  ),
),

  home: const SplashScreen(),
);
  }
}