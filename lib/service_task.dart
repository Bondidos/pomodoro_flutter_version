import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pomodoro_flutter_version/util/util.dart';
import 'package:quiver/async.dart';

class FirstTaskHandler extends TaskHandler {
  CountdownTimer? timer;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    final customData =
        await FlutterForegroundTask.getData<int>(key: 'currentTimer');
    // init timer
    timer = CountdownTimer(
      Duration(milliseconds: customData ?? 0),
      const Duration(milliseconds: 1000),
    );

    var sub = timer?.listen(null);
    sub?.onData(
      (duration) {
        FlutterForegroundTask.updateService(
          notificationText: displayTime(duration.remaining.inMilliseconds.toDouble())
        );
      },
    );

    sub?.onDone(() {
      FlutterForegroundTask.updateService(
          notificationText: 'CountDown is over',
      );
    });

    // print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
    print('event');
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
    timer?.cancel();
    timer = null;
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }
}
