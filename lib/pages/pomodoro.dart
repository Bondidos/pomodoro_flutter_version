import 'package:quiver/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_flutter_version/util/util.dart';

import '../painted_widgets/drawDot.dart';
import '../painted_widgets/drawFillingCircle.dart';
import '../timer_model/model.dart';

class Pomodoro extends StatefulWidget {
  const Pomodoro({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PomodoroState();
}

class PomodoroState extends State<Pomodoro> {
  List<PomodoroItem> list = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _addNewTimerController = TextEditingController();
  CountdownTimer? timer;


  String? _error;

  String? _errorInputText() => _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      width: 250,
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

  Widget item(BuildContext context, PomodoroItem item) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black12,
          ),
          // color: Colors.amberAccent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomPaint(
                foregroundPainter: DotPainter(context: context),
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
                  if(!item.isStarted && !item.isFinished){
                    timer = CountdownTimer(
                      Duration(milliseconds: item.currentMsState.toInt()),
                      const Duration(milliseconds: 100),
                    );

                    item.isStarted = timer?.isRunning ?? false;
                    print(item.isStarted);
                    var sub = timer?.listen(null);
                    sub?.onData((duration) {
                      setState(() {
                        item.currentMsState -= duration.increment.inMilliseconds;
                        // print(duration.increment.inMilliseconds);
                      });
                    });
                    sub?.onDone(() {
                      item.isStarted = false;
                      if(item.currentMsState <= 0){
                        item.isFinished = true;
                        item.currentMsState = item.futureMsState;
                      }
                      // item.isFinished = true;
                      // timer = null;
                      print(item.isFinished);
                    });
                  } else if(item.isStarted && !item.isFinished){
                      timer?.cancel();
                      timer = null;
                      setState(() {
                        item.isStarted = false;
                      });
                  }
                },
                child: Text(item.isStarted ? 'Stop' : 'Start'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    list.remove(item);
                  });
                },
              ),
            ],
          ),
        ),
      );
}
