import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/roadside_service.dart';
import 'package:geolocator/geolocator.dart';

class RoadsideScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const RoadsideScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<RoadsideScreen> createState() =>
      _RoadsideScreenState();
}

class _RoadsideScreenState
    extends State<RoadsideScreen> {

  bool loading = false;

  List<dynamic> places = [];

  String selectedType = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadPlaces(String type) async {

  setState(() {
    loading = true;
    selectedType = type;
  });

  try {
    final result = await RoadsideService().getNearbyRoadside(
      widget.latitude,
      widget.longitude,
      type,
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
      places = result;
      loading = false;
    });

  } catch (e) {
    if (!mounted) return;

    setState(() {
      loading = false;
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
      "https://www.google.com/maps/search/?api=1&query=$lat,$lon");

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

  Widget optionCard(
      IconData icon,
      String title,
      Color color,
      String type,
      ) {
    
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => loadPlaces(type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Roadside Assistance",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [
            optionCard(
  Icons.car_repair,
  "Vehicle Repair",
  Colors.blue,
  "repair",
),
            

            optionCard(
              Icons.local_gas_station,
              "Fuel Station",
              Colors.green,
              "fuel",
            ),

            

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            if (!loading)

              Expanded(
                child: ListView.builder(

                  itemCount: places.length,

                  itemBuilder: (context, index) {

                    final place = places[index];
                    final distance = calculateDistance(
  place["properties"]["lat"],
  place["properties"]["lon"],
);
                    final phone =
    place["properties"]["contact"]?["phone"];
                      return Card(
  margin: const EdgeInsets.symmetric(
    vertical: 8,
  ),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            CircleAvatar(
  backgroundColor: Colors.deepOrange,
  child: Icon(
    selectedType == "fuel"
    ? Icons.local_gas_station
    : Icons.car_repair,
    color: Colors.white,
  ),
),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                place["properties"]["name"] ??
"Unnamed Place",
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
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const Icon(
      Icons.location_on,
      color: Colors.red,
      size: 20,
    ),

    const SizedBox(width: 8),

    Expanded(
      child: Text(
        place["properties"]["formatted"] ??
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
  const SizedBox(height: 10),

  Row(
    children: [

      const Icon(
        Icons.phone,
        color: Colors.green,
        size: 18,
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(phone),
      ),
    ],
  ),
],
const Divider(height: 30),
const SizedBox(height: 12),

        

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
        place["properties"]["lat"],
        place["properties"]["lon"],
      );
    },
  ),
),
  ],
)
      ],
    ),
  ),

                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}