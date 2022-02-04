import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:quiver/async.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_flutter_version/util/util.dart';

import '../painted_widgets/drawDot.dart';
import '../painted_widgets/drawFillingCircle.dart';
import '../service_task.dart';
import '../timer_model/model.dart';

class Pomodoro extends StatefulWidget {
  const Pomodoro({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PomodoroState();
}

void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
   FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
  print('callback');
}

//todo https://pub.dev/documentation/flutter_foreground_task/latest/






class PomodoroState extends State<Pomodoro> with TickerProviderStateMixin{

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  
  late final Animation<double> _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
  );
/*
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }*/

  List<PomodoroItem> list = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _addNewTimerController = TextEditingController();
  CountdownTimer? timer;

  String? _error;

  String? _errorInputText() => _error;

  String timeService(){
    return displayTime(timer?.remaining.inMilliseconds.toDouble() ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return WillStartForegroundTask(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'Pomodoro_channel',
        channelName: 'Pomodoro Notification',
        channelDescription: 'Shows Pomodoro\'s time count.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.drawable,
          resPrefix: ResourcePrefix.ic,
          name: 'timer',
        ),
      ),
      printDevLog: true,
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        allowWifiLock: false,
        autoRunOnBoot: false,
      ),
      notificationText: timeService(),
      onWillStart: () async {
        //this method pass into the service timer value
        // todo write here  logic save timer state and cancel
        if(timer != null && (timer?.isRunning ?? false) ){
          await FlutterForegroundTask.saveData(key: 'currentTimer', value: timer?.remaining.inMilliseconds ?? 0);
          timer?.cancel();
          timer = null;
          return true;
        } else{
          FlutterForegroundTask.stopService();
        }
        return false;
      },
      callback: startCallback,
      notificationTitle: 'Pomodoro',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pomodoro'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 9,
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return item(
                      context,
                      list[index],
                    );
                  }),
            ),
            Expanded(
              flex: 1,
              child: Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        width: 200,
                        child: TextFormField(
                          controller: _addNewTimerController,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          decoration: InputDecoration(
                            errorText: _errorInputText(),
                            hintText: 'Inter value, seconds',
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _error = _formKey.currentState!.validate() != null
                                ? _formKey.currentState!.validate().toString()
                                : null;
                            addNewTimer();
                          }
                        },
                        child: const Text('AddTimer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void addNewTimer() {
    setState(() {
      list.add(PomodoroItem(
          id: list.length,
          isStarted: false,
          isFinished: false,
          currentMsState: double.parse(_addNewTimerController.text) * 1000,
          futureMsState: double.parse(_addNewTimerController.text) * 1000));
    });
  }

  Widget fadingDot(BuildContext context) {
    return  FadeTransition(
        opacity: _animation,
        child: CustomPaint(
          foregroundPainter: DotPainter(context: context),
        ),
      );
  }

  Widget item(BuildContext context, PomodoroItem item) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (item.isFinished) ? Colors.deepOrangeAccent : Colors.black12,
          ),
          // color: Colors.amberAccent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: item.isStarted ? fadingDot(context) : null,
              ),
              Text(
                displayTime(item.currentMsState),
                style: const TextStyle(fontSize: 20), //TODO AWESOME STYLE
              ),
              CustomPaint(
                foregroundPainter: FillingCircle(
                  currentMs: item.currentMsState,
                  periodMs: item.futureMsState,
                  context: context,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  countDownTimer(item);
                },
                child: Text(item.isStarted ? 'Stop' : 'Start'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    if(item.isStarted){
                      timer?.cancel();
                      timer = null;
                    }
                    list.remove(item);
                  });
                },
              ),
            ],
          ),
        ),
      );

  void countDownTimer(PomodoroItem item) {
    if (!item.isStarted) {
      item.isFinished = false;
      timer?.cancel();
      timer = CountdownTimer(
        Duration(milliseconds: item.currentMsState.toInt()),
        const Duration(milliseconds: 100),
      );

      item.isStarted = timer?.isRunning ?? false;
      var sub = timer?.listen(null);
      sub?.onData((duration) {
        setState(() {
          item.currentMsState -= duration.increment.inMilliseconds;
        });
      });
      sub?.onDone(() {
        item.isStarted = false;
        if (item.currentMsState <= 0) {
          item.isFinished = true;
          item.currentMsState = item.futureMsState;
        }
        timer = null;
      });
    } else if (item.isStarted && !item.isFinished) {
      timer?.cancel();
      timer = null;
      setState(() {
        item.isStarted = false;
      });
    }
  }
}
