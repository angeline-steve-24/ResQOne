import 'package:flutter/services.dart';

class SmsService {
  static const MethodChannel _channel =
      MethodChannel('roadsos/sms');

  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final numbers = phoneNumber
          .split(',')
          .map((number) => number.trim())
          .where((number) => number.isNotEmpty)
          .toList();

      if (numbers.isEmpty) {
        print("No emergency contacts found");
        return false;
      }

      for (final number in numbers) {
        print("📤 Sending SOS SMS to $number");

        final result = await _channel.invokeMethod(
          'sendSMS',
          {
            'phoneNumber': number,
            'message': message,
          },
        );

        if (result == true) {
          print("✅ SMS request sent to $number");
        }

        await Future.delayed(
          const Duration(milliseconds: 500),
        );
      }

      return true;
    } on PlatformException catch (e) {
      print(
        "❌ SMS Error: ${e.code} - ${e.message}",
      );

      return false;
    } catch (e) {
      print("❌ SMS Error: $e");
      return false;
    }
  }
}