# ResQOne

**A Mobile-Based Intelligent Emergency Response System for Road Safety**

ResQOne is a Flutter-based mobile emergency response application designed to provide multiple road-safety and emergency assistance features through a single platform. It combines manual emergency activation, automatic accident detection, location services, emergency SMS, Medical ID, nearby emergency services, first-aid guidance, roadside assistance, emergency contacts, and accident history.

## Features

1. **SafeSphere** — Manual emergency activation with a 5-second countdown
2. **Protection Mode** — Continuous accident monitoring
3. **Accident Detection** — Detects abnormal movements using the device accelerometer
4. **Current Location** — Retrieves latitude and longitude using Geolocator
5. **Emergency SMS** — Sends emergency alerts with location to multiple contacts
6. **Emergency Contacts** — Manage trusted emergency contacts
7. **Medical ID** — Stores and displays important medical information during emergencies
8. **Emergency Numbers** — Quick access to 108, 100, and 112
9. **Nearby Services** — Find nearby hospitals, police stations, and roadside assistance
10. **First Aid** — Provides emergency first-aid guidance
11. **Roadside Assistance** — Location-based roadside support
12. **Accident History** — Stores previous emergency records
13. **Offline Emergency Support** — Core emergency functions can continue without internet connectivity

## System Architecture

```text
                    RESQONE
                       |
             Flutter Mobile Application
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
   Geolocator     Accelerometer   Emergency
   GPS Location   Crash Detection Communication
        |              |              |
        +--------------+--------------+
                       |
                       v
              Firebase / Firestore
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
Emergency Contacts  Medical ID   Accident History
                       |
                       v
              Google Maps Platform
                       |
                       v
             Nearby Location Services

Emergency Workflow
Manual Emergency
