import 'package:flutter/material.dart';
import '../services/police_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class PoliceScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const PoliceScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PoliceScreen> createState() =>
      _PoliceScreenState();
}

class _PoliceScreenState
    extends State<PoliceScreen> {

  List policeStations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPoliceStations();
  }

  Future<void> loadPoliceStations() async {
  try {
    final result = await PoliceService().getNearbyPolice(
      widget.latitude,
      widget.longitude,
    );
    result.sort((a, b) {
  final d1 = Geolocator.distanceBetween(
    widget.latitude,
    widget.longitude,
    a["properties"]["lat"],
    a["properties"]["lon"],
  );

  final d2 = Geolocator.distanceBetween(
    widget.latitude,
    widget.longitude,
    b["properties"]["lat"],
    b["properties"]["lon"],
  );

  return d1.compareTo(d2);
});

    if (!mounted) return;

    setState(() {
      policeStations = result;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    debugPrint(e.toString());
  }
}

Future<void> callNumber(String number) async {
  final Uri uri = Uri(
    scheme: 'tel',
    path: number,
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> openMap(
  double lat,
  double lon,
) async {
  final Uri url = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}

double calculateDistance(
  double lat,
  double lon,
) {
  return Geolocator.distanceBetween(
    widget.latitude,
    widget.longitude,
    lat,
    lon,
  );
}

String formatDistance(double distanceInMeters) {
  if (distanceInMeters < 1000) {
    return "${distanceInMeters.round()} m away";
  }

  return "${(distanceInMeters / 1000).toStringAsFixed(1)} km away";
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nearby Police Stations",
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : policeStations.isEmpty
              ? const Center(
                  child: Text(
                    "No police stations found nearby",
                  ),
                )
              : ListView.builder(
                  itemCount: policeStations.length,
                  itemBuilder:
                      (context, index) {

                    final police =
                        policeStations[index];
                    final distance = calculateDistance(
  police["properties"]["lat"],
  police["properties"]["lon"],
);

                    final phone =
    police["properties"]["contact"]?["phone"];

return Card(
  margin: const EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 10,
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.local_police,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                police["properties"]["name"] ??
                    "Unnamed Police Station",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Icon(
              Icons.location_on,
              color: Colors.red,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                police["properties"]["formatted"] ??
                    "Address unavailable",
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

Row(
  children: [
    const Icon(
      Icons.near_me,
      color: Colors.blue,
      size: 18,
    ),

    const SizedBox(width: 8),

    Text(
      formatDistance(distance),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.blue,
      ),
    ),
  ],
),

        if (phone != null) ...[
          const SizedBox(height: 12),

          Row(
            children: [

              const Icon(
                Icons.phone,
                color: Colors.green,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(phone),
              ),
            ],
          ),
        ],
        const Divider(height: 30),

        const SizedBox(height: 18),

        Row(
          children: [

            if (phone != null)
              Expanded(
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
    icon: const Icon(Icons.call),
    label: const Text("Call"),
    onPressed: () {
      callNumber(phone);
    },
  ),
),

            if (phone != null)
              const SizedBox(width: 10),

            Expanded(
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    icon: const Icon(Icons.directions),
    label: const Text("Navigate"),
    onPressed: () {
      openMap(
        police["properties"]["lat"],
        police["properties"]["lon"],
      );
    },
  ),
),
          ],
        ),
      ],
    ),
  ),
);
                  },
                ),
    );
  }
}