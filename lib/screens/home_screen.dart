import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';
import 'emergency_contacts_screen.dart';
import 'accident_history_screen.dart';
import 'hospitals_screen.dart';
import 'police_screen.dart';
import '../services/call_service.dart';
import '../services/sms_service.dart';
import '../services/crash_detection_service.dart';
import 'first_aid_screen.dart';
import 'roadside_screen.dart';
import '../services/hospital_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../services/foreground_task_handler.dart';
import 'medical_id_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin  {
  String locationText = "Getting location...";
  Position? currentPosition;
  late AnimationController _controller;
late Animation<double> _animation;
  final CrashDetectionService
    _crashService =
        CrashDetectionService();

bool _crashDialogShowing = false;
bool isProtectionEnabled = false;
  
@override
void initState() {
  super.initState();

  FlutterForegroundTask.addTaskDataCallback(
    _onReceiveTaskData,
  );

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  _animation = Tween<double>(
    begin: 1.0,
    end: 1.1,
  ).animate(_controller);

  getLocation();

  _crashService.startListening(
    onCrashDetected,
  );
}

@override
void dispose() {
  FlutterForegroundTask.removeTaskDataCallback(
  _onReceiveTaskData,
);
  _controller.dispose();
  _crashService.stopListening();
  super.dispose();
}


void _onReceiveTaskData(Object data) {
  debugPrint("Received: $data");

  if (data == "CRASH_DETECTED") {
    onCrashDetected();
  }
}

void onCrashDetected() {
  if (!mounted) return;

  if (!isProtectionEnabled) return;

  if (_crashDialogShowing) return;

  _crashDialogShowing = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      Future.delayed(
        const Duration(seconds: 5),
        () {
          if (!mounted) return;

          if (_crashDialogShowing) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }

            _crashDialogShowing = false;

            sendSOS();
          }
        },
      );

      return AlertDialog(
        title: const Text(
          "⚠️ Possible Accident Detected",
        ),

        content: const Text(
          "SOS will be sent automatically in 5 seconds.",
        ),

        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }

              _crashDialogShowing = false;
            },
            child: const Text(
              "I'm OK",
            ),
          ),

          ElevatedButton(
            onPressed: () {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }

              _crashDialogShowing = false;

              sendSOS();
            },
            child: const Text(
              "Send SOS",
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> showSOSConfirmation() async {

  bool cancelled = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {

      Future.delayed(
        const Duration(seconds: 5),
        () {
          if (!cancelled &&
              Navigator.canPop(context)) {

            Navigator.pop(context);
            sendSOS();
          }
        },
      );

      return AlertDialog(
        title: const Text(
          "🆘 ResQOne Emergency Alert",
        ),

        content: const Text(
          "This emergency alert will be sent automatically in 5 seconds.",
        ),

        actions: [

          TextButton(
            onPressed: () {
              cancelled = true;
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
            ),
          ),

          ElevatedButton(
            onPressed: () {
              cancelled = true;
              Navigator.pop(context);
              sendSOS();
            },
            child: const Text(
              "Send Now",
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> getLocation() async {
    try {
      Position position =
          await LocationService().getCurrentLocation();

      currentPosition = position;
      print("Latitude: ${position.latitude}");
print("Longitude: ${position.longitude}");
      // Preload nearby hospitals in the background
      
HospitalService().getNearbyHospitals(
  position.latitude,
  position.longitude,
);

      setState(() {
        locationText =
            "Latitude: ${position.latitude}\nLongitude: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        locationText = e.toString();
      });
    }
  }

  Future<void> sendSOS() async {
  if (currentPosition == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Location not available"),
      ),
    );
    return;
  }

  final latitude = currentPosition!.latitude;
  final longitude = currentPosition!.longitude;

  // =====================================================
  // 1. GET EMERGENCY CONTACTS
  // =====================================================

  final contacts =
      await FirestoreService().getContacts();

  debugPrint(
    "📱 CONTACT COUNT: ${contacts.length}",
  );

  for (final contact in contacts) {
    debugPrint(
      "📞 CONTACT: ${contact['name']} - ${contact['phone']}",
    );
  }

  // =====================================================
  // 2. PREPARE EMERGENCY MESSAGE
  // =====================================================

  final message = '''
🆘 RESQONE EMERGENCY SIGNAL

This is an automated emergency alert from ResQOne.

⚠️ The user may be in an emergency and may be unable to respond.

📍 LOCATION
https://maps.google.com/?q=$latitude,$longitude

Please check the location and contact the user immediately.

⏱️ Sent automatically by ResQOne.
''';

  // =====================================================
  // 3. SEND SMS
  // =====================================================

  if (contacts.isNotEmpty) {
    final phones = contacts
        .map((contact) => contact['phone'])
        .join(',');

    try {
      await SmsService.sendSMS(
        phoneNumber: phones,
        message: message,
      );

      debugPrint(
        "✅ Emergency SMS process completed.",
      );
    } catch (e) {
      debugPrint(
        "❌ SMS error: $e",
      );
    }
  } else {
    debugPrint(
      "⚠️ No emergency contacts available.",
    );
  }

  // =====================================================
  // 4. SAVE SOS TO FIRESTORE IN BACKGROUND
  // =====================================================

  FirestoreService()
      .sendSOS(
        latitude: latitude,
        longitude: longitude,
      )
      .then((_) {
        debugPrint(
          "✅ SOS saved to Firestore.",
        );
      })
      .catchError((e) {
        debugPrint(
          "⚠️ Firestore unavailable. SOS continues offline.",
        );
      });

  // =====================================================
  // 5. OPEN MEDICAL ID IMMEDIATELY
  // =====================================================

  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MedicalIdScreen(
        isEmergency: true,
      ),
    ),
  );
}

Future<void> toggleProtection() async {

  setState(() {
    isProtectionEnabled = !isProtectionEnabled;
  });

  if (isProtectionEnabled) {
    debugPrint("Starting foreground service...");
    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: "RoadSOS Protection",
      notificationText: "Monitoring for accidents...",
      callback: startCallback,
    );
    debugPrint("Foreground service start requested");

  } else {

    await FlutterForegroundTask.stopService();

  }

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isProtectionEnabled
            ? "🛡 Protection Enabled"
            : "Protection Disabled",
      ),
    ),
  );
}

Widget protectionCard() {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          Row(
            children: const [

              Icon(
                Icons.shield,
                color: Colors.green,
                size: 35,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Protection Mode",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 12),

          Text(
            isProtectionEnabled
                ? "Crash Detection is Active"
                : "Enable protection before travelling.",
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isProtectionEnabled
                        ? Colors.red
                        : Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                isProtectionEnabled
                    ? Icons.stop
                    : Icons.shield,
              ),
              label: Text(
                isProtectionEnabled
                    ? "Stop Protection"
                    : "Enable Protection",
              ),
              onPressed: toggleProtection,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget serviceCard(
  IconData icon,
  String title,
  Color color,
  VoidCallback onTap,
) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ResQOne 🛡️",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const EmergencyContactsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AccidentHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// LOCATION CARD
            InkWell(
  borderRadius: BorderRadius.circular(20),
  onTap: () {
    if (currentPosition == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
        ),
      ),
    );
  },
  child: Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: ListTile(
      leading: const Icon(
        Icons.location_on,
        color: Colors.red,
        size: 35,
      ),
      title: const Text(
        "Current Location",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(locationText),
      trailing: const Icon(Icons.map),
    ),
  ),
),

const SizedBox(height: 20),

/// SOS BUTTON
GestureDetector(
  onTap: showSOSConfirmation,
  child: ScaleTransition(
    scale: _animation,
    child: Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 65,
          ),
          SizedBox(height: 10),
          Text(
            "SafeSphere",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Tap for Help",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  ),
),

const SizedBox(height: 30),

/// ROAD SOS PROTECTION
protectionCard(),

const SizedBox(height: 20),

/// MEDICAL ID
Card(
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: ListTile(
    leading: const Icon(
      Icons.medical_information,
      color: Colors.red,
      size: 32,
    ),
    title: const Text(
      "Medical ID",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: const Text(
      "Emergency medical information",
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      size: 18,
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MedicalIdScreen(),
        ),
      );
    },
  ),
),

const SizedBox(height: 30),

            const SizedBox(height: 30),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Emergency Numbers",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 10),

Card(
  child: ListTile(
    leading: const Icon(
      Icons.local_hospital,
      color: Colors.red,
    ),
    title: const Text("108 Ambulance"),
    trailing: IconButton(
      icon: const Icon(Icons.call),
      onPressed: () {
        CallService.makeCall("108");
      },
    ),
  ),
),

Card(
  child: ListTile(
    leading: const Icon(
      Icons.local_police,
      color: Colors.blue,
    ),
    title: const Text("100 Police"),
    trailing: IconButton(
      icon: const Icon(Icons.call),
      onPressed: () {
        CallService.makeCall("100");
      },
    ),
  ),
),

Card(
  child: ListTile(
    leading: const Icon(
      Icons.warning,
      color: Colors.orange,
    ),
    title: const Text("112 Emergency"),
    trailing: IconButton(
      icon: const Icon(Icons.call),
      onPressed: () {
        CallService.makeCall("112");
      },
    ),
  ),
),

const SizedBox(height: 35),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Nearby Services",
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
),

const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [

  serviceCard(
  Icons.local_hospital,
  "Hospitals",
  Colors.red,
  () {
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Getting your location..."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalsScreen(
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
        ),
      ),
    );
  },
),

  

  serviceCard(
  Icons.local_police,
  "Police",
  Colors.blue,
  () {
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PoliceScreen(
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
    ),
  ),
);
  },
),

  serviceCard(
  Icons.medical_services,
  "First Aid",
  Colors.green,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const FirstAidScreen(),
      ),
    );
  },
),

serviceCard(
  Icons.car_repair,
  "Roadside",
  Colors.deepOrange,
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
           RoadsideScreen(
  latitude: currentPosition!.latitude,
  longitude: currentPosition!.longitude,
)
      ),
    );
  },
),
],
            ),
          ],
        ),
      ),
    );
  }
}