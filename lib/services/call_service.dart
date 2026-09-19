import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<void> makeCall(
    String number,
  ) async {

    final Uri phoneUri =
        Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}