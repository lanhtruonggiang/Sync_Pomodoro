import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String name;
  final int initialTotalSeconds;
  int remainingSeconds;
  bool isRunning;
  DateTime? targetEndTime;

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

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'initialTotalSeconds': initialTotalSeconds,
      'remainingSeconds': remainingSeconds,
      'isRunning': isRunning,
      'targetEndTime': targetEndTime != null ? Timestamp.fromDate(targetEndTime!) : null,
    };
  }

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    final Timestamp? timestamp = data['targetEndTime'] as Timestamp?;
    
    return TaskModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      initialTotalSeconds: (data['initialTotalSeconds'] as int?) ?? 0,
      remainingSeconds: (data['remainingSeconds'] as int?) ?? 0,
      isRunning: data['isRunning'] as bool? ?? false,
      targetEndTime: timestamp?.toDate(),
    );
  }
}