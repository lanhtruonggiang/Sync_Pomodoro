import 'dart:async';

class TaskModel {
  final String id;
  final String name;
  final int initialTotalSeconds; // Thời gian thiết lập ban đầu (dùng cho Reset)
  int remainingSeconds;          // Thời gian còn lại hiện tại
  bool isRunning;
  DateTime? targetEndTime;      // Mốc thời gian đích khi đang chạy
  Timer? timer;

  TaskModel({
    required this.id,
    required this.name,
    required this.initialTotalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.targetEndTime,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initialTotalSeconds': initialTotalSeconds,
      'remainingSeconds': remainingSeconds,
      'isRunning': isRunning,
      'targetEndTime': targetEndTime?.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      initialTotalSeconds: (json['initialTotalSeconds'] as int?) ?? (json['remainingSeconds'] as int),
      remainingSeconds: json['remainingSeconds'] as int,
      isRunning: json['isRunning'] as bool? ?? false,
      targetEndTime: json['targetEndTime'] != null
          ? DateTime.parse(json['targetEndTime'] as String)
          : null,
    );
  }
}