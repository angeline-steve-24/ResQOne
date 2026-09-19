ResQOne 🛡️

A Mobile-Based Intelligent Emergency Response System for Road Safety

ResQOne is a Flutter-based mobile emergency response application designed to provide multiple road-safety and emergency assistance features through a single platform. It combines manual emergency activation, automatic accident detection, location services, emergency SMS, Medical ID, nearby emergency services, first-aid guidance, roadside assistance, emergency contacts, and accident history.

🚨 Features
SafeSphere — Manual emergency activation with a 5-second countdown
Protection Mode — Continuous accident monitoring
Accident Detection — Detects abnormal movements using the device accelerometer
Current Location — Retrieves latitude and longitude using Geolocator
Emergency SMS — Sends emergency alerts with location to multiple contacts
Emergency Contacts — Manage trusted emergency contacts
Medical ID — Stores and displays important medical information during emergencies
Emergency Numbers — Quick access to 108, 100, and 112
Nearby Services — Find nearby hospitals, police stations, and roadside assistance
First Aid — Provides emergency first-aid guidance
Roadside Assistance — Location-based roadside support
Accident History — Stores previous emergency records
Offline Emergency Support — Core emergency functions can continue without internet connectivity
🏗️ System Architecture
              ┌──────────────────────┐
              │    ResQOne Flutter    │
              │      Application      │
              └──────────┬───────────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
     Geolocator      Accelerometer   Emergency
     GPS Location    Crash Detection Communication
          │              │              │
          └──────────────┼──────────────┘
                         ▼
              ┌──────────────────────┐
              │       Firebase       │
              │    Cloud Firestore   │
              └──────────┬───────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
     Emergency       Medical ID     Accident History
      Contacts
                         │
                         ▼
              ┌──────────────────────┐
              │ Google Maps Platform │
              │  Nearby Services     │
              └──────────────────────┘
🔄 Emergency Workflow
Manual Emergency
SafeSphere
    ↓
5-Second Countdown
    ↓
Emergency Triggered
    ↓
Get Current Location
    ↓
Send Emergency SMS
    ↓
Save Emergency Record
    ↓
Display Medical ID
Automatic Accident Detection
Protection Mode
      ↓
Accelerometer Monitoring
      ↓
Abnormal Movement Detected
      ↓
5-Second Countdown
      ↓
User Cancels / SOS Triggered
      ↓
Emergency SMS
      ↓
Medical ID
🛠️ Technologies Used
Technology	Purpose
Flutter	Mobile application development
Dart	Application programming
Firebase	Backend services
Cloud Firestore	Data storage
Geolocator	GPS location
Google Maps Platform	Maps and location-based services
sensors_plus	Accelerometer-based detection
flutter_foreground_task	Background accident monitoring
SharedPreferences	Local offline contact storage
SMS Services	Emergency communication
Phone Call Services	Emergency calls
Git & GitHub	Version control
📂 Project Structure
lib/
├── screens/
│   ├── home_screen.dart
│   ├── medical_id_screen.dart
│   ├── emergency_contacts_screen.dart
│   ├── accident_history_screen.dart
│   ├── hospitals_screen.dart
│   ├── police_screen.dart
│   ├── first_aid_screen.dart
│   ├── roadside_screen.dart
│   └── map_screen.dart
│
├── services/
│   ├── location_service.dart
│   ├── firestore_service.dart
│   ├── sms_service.dart
│   ├── call_service.dart
│   ├── crash_detection_service.dart
│   ├── hospital_service.dart
│   └── foreground_task_handler.dart
│
├── main.dart
└── firebase_options.dart
📱 Offline Support

ResQOne is designed so that loss of internet connectivity does not completely prevent emergency assistance.

Available offline
SafeSphere
Protection Mode
Accelerometer accident detection
GPS location
Medical ID
First Aid
Cached emergency contacts
SMS and phone calls, subject to cellular availability
Requires Internet
Firebase cloud synchronization
New nearby-service searches
Online Google Maps data
Cloud-based notifications
⚙️ Installation
1. Clone the repository
git clone <YOUR-GITHUB-REPOSITORY-URL>
cd roadsos
2. Install dependencies
flutter pub get
3. Configure Firebase

Add your Firebase configuration for the Android/iOS platform as required by your Firebase project.

4. Configure Google Maps

Add your Google Maps API key according to the platform configuration.

5. Run the application
flutter run
🧪 Testing

The application has been tested for:

Manual emergency activation
5-second emergency countdown
Emergency SMS delivery
Multiple emergency contacts
GPS location retrieval
Protection Mode
Accelerometer-based accident detection
Medical ID display
Emergency phone calls
First Aid access
Nearby services
Accident history
Offline emergency workflow
🔐 Data & Privacy

The application uses Firebase Cloud Firestore for storing application data such as emergency contacts, Medical ID information, and emergency records. Local caching is used for emergency contacts to support offline operation.

🚀 Future Enhancements

Potential future improvements include:

Advanced accident detection algorithms
Improved emergency coordination
Real-time location sharing
Enhanced offline synchronization
Additional emergency assistance features
Intelligent emergency severity analysis
👩‍💻 Development

Project: ResQOne
Platform: Flutter
Domain: Road Safety & Emergency Response
Repository: GitHub

ResQOne brings essential emergency assistance features together in one mobile application, helping users access emergency communication, location services, medical information, and safety support from a single platform.
