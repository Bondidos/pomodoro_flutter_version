String displayTime(double currentMs){
  if(currentMs <= 0.0) return '00:00:00:00';
  // 50 ms
  double h = currentMs / 1000 / 3600 ;
  double m = currentMs / 1000 % 3600 / 60;
  double s = currentMs / 1000 % 60;
  double ms = currentMs % 1000 / 10;

  return "${_displaySlot(h)}:${_displaySlot(m)}:${_displaySlot(s)}:${_displaySlot(ms)}";
  //:${_displaySlot(m)}:${_displaySlot(s)}:${_displaySlot(ms)}
}
String _displaySlot(double count){
   if(count.toInt() ~/ 10 > 0){
     return "${count.toInt()}";
  } else {
     return "0${count.toInt()}";
   }
}