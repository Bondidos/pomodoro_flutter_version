class PomodoroItem{
  int id;
  bool isStarted;
  bool isFinished;
  double currentMsState;
  double futureMsState;

  PomodoroItem({
    required this.id,
    required this.isStarted,
    required this.isFinished,
    required this.currentMsState,
    required this.futureMsState,
  });
}