import 'dart:async';

class TaskModel {
  final String id;
  final String name;
  int remainingSeconds;
  bool isRunning;
  Timer? timer;

  TaskModel({
    required this.id,
    required this.name,
    required this.remainingSeconds,
    this.isRunning = false,
  });

  String get formattedTime {
    int hours = remainingSeconds ~/ 3600;
    int minutes = (remainingSeconds % 3600) ~/ 60;
    int seconds = remainingSeconds % 60;

    String hStr = hours.toString().padLeft(2, '0');
    String mStr = minutes.toString().padLeft(2, '0');
    String sStr = seconds.toString().padLeft(2, '0');

    return "$hStr:$mStr:$sStr";
  }
}