import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HospitalService {
  static List<dynamic>? _cachedHospitals;
  static DateTime? _lastFetchTime;
  static Future<List<dynamic>>? _ongoingRequest;

  // Replace with your Geoapify API Key
  static const String apiKey = "3ba796da7576464ead47a81cfd888e39";

  Future<List<dynamic>> getNearbyHospitals(
      double lat, double lon) {
    if (_cachedHospitals != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(minutes: 10)) {
      return Future.value(_cachedHospitals!);
    }

    if (_ongoingRequest != null) {
      return _ongoingRequest!;
    }

    _ongoingRequest = _fetchHospitals(lat, lon);
    return _ongoingRequest!;
  }

  Future<List<dynamic>> _fetchHospitals(
      double lat, double lon) async {
    final url =
        "https://api.geoapify.com/v2/places"
        "?categories=healthcare.hospital"
        "&filter=circle:$lon,$lat,5000"
        "&limit=20"
        "&apiKey=$apiKey";

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _cachedHospitals = data["features"] ?? [];
        _lastFetchTime = DateTime.now();

        print("Hospitals Found: ${_cachedHospitals!.length}");

        return _cachedHospitals!;
      }

      print(response.body);
      return [];
    } catch (e) {
      print(e);
      return [];
    } finally {
      _ongoingRequest = null;
    }
  }
}