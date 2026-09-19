import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(
    RoadSOSTaskHandler(),
  );
}

class RoadSOSTaskHandler extends TaskHandler {
  StreamSubscription? _subscription;

bool _crashDetected = false;

  @override
Future<void> onStart(
  DateTime timestamp,
  TaskStarter starter,
) async {

  FlutterForegroundTask.updateService(
    notificationTitle: "RoadSOS Protection",
    notificationText: "Monitoring for accidents...",
  );

  _subscription =
      accelerometerEventStream().listen((event) {

    final force =
        event.x.abs() +
        event.y.abs() +
        event.z.abs();

    if (force > 40 && !_crashDetected) {

      _crashDetected = true;

      FlutterForegroundTask.sendDataToMain(
        "CRASH_DETECTED",
      );
      Future.delayed(
  const Duration(seconds: 10),
  () {
    _crashDetected = false;
  },
);
    }

  });

}

  
  @override


void onRepeatEvent(DateTime timestamp) {}

  

  @override
  void onReceiveData(Object data) {}
  @override
Future<void> onDestroy(
  DateTime timestamp,
  bool isTimeout,
) async {

  await _subscription?.cancel();

}
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/");
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationDismissed() {}
}