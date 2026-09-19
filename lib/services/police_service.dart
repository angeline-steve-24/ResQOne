import 'dart:convert';
import 'package:http/http.dart' as http;

class PoliceService {
  static const String apiKey = "3ba796da7576464ead47a81cfd888e39";

  static List<dynamic>? _cachedPolice;
  static Future<List<dynamic>>? _ongoingRequest;

  Future<List<dynamic>> getNearbyPolice(
    double lat,
    double lon,
  ) async {
    if (_cachedPolice != null) {
      return _cachedPolice!;
    }

    if (_ongoingRequest != null) {
      return _ongoingRequest!;
    }

    final url =
        "https://api.geoapify.com/v2/places?"
        "categories=service.police"
        "&filter=circle:$lon,$lat,5000"
        "&limit=20"
        "&apiKey=$apiKey";

    _ongoingRequest = () async {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      print("Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _cachedPolice = data["features"];

        print("Police Stations Found: ${_cachedPolice!.length}");

        return _cachedPolice!;
      }

      return <dynamic>[];
    }();

    try {
      return await _ongoingRequest!;
    } finally {
      _ongoingRequest = null;
    }
  }
}