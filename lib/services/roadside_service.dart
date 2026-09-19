import 'dart:convert';
import 'package:http/http.dart' as http;

class RoadsideService {
  static const String apiKey = "3ba796da7576464ead47a81cfd888e39";

  static final Map<String, List<dynamic>> _cache = {};
  static final Map<String, Future<List<dynamic>>> _ongoingRequests = {};

  Future<List<dynamic>> getNearbyRoadside(
    double lat,
    double lon,
    String type,
  ) async {
    if (_cache.containsKey(type)) {
      return _cache[type]!;
    }

    if (_ongoingRequests.containsKey(type)) {
      return _ongoingRequests[type]!;
    }

    String category;

switch (type) {
  case "repair":
    category = "service.vehicle.repair";
    break;

  case "fuel":
    category = "service.vehicle.fuel";
    break;

  default:
    category = "service.vehicle.repair";
}

    final url =
        "https://api.geoapify.com/v2/places?"
        "categories=$category"
        "&filter=circle:$lon,$lat,10000"
        "&limit=20"
        "&apiKey=$apiKey";

    _ongoingRequests[type] = () async {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _cache[type] = data["features"];

        print("$type Found: ${_cache[type]!.length}");

        return _cache[type]!;
      }

      return <dynamic>[];
    }();

    try {
      return await _ongoingRequests[type]!;
    } finally {
      _ongoingRequests.remove(type);
    }
  }
}