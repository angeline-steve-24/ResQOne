import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

class CrashDetectionService {
  StreamSubscription? _subscription;

  void startListening(
    Function() onCrashDetected,
  ) {
    _subscription =
        accelerometerEventStream().listen(
      (event) {
        double force =
            event.x.abs() +
            event.y.abs() +
            event.z.abs();

        if (force > 40) {
          onCrashDetected();
        }
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
  }
}