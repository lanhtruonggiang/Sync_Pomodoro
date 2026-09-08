import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  final List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  // Validation kiểm tra tên trùng lặp (không phân biệt hoa/thường)
  bool isTaskNameDuplicate(String name) {
    return _tasks.any(
      (task) => task.name.trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }

  // Auto normalize thời gian quy đổi ra tổng số giây
  int normalizeToSeconds(int hours, int minutes, int seconds) {
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  void addTask(String name, int hours, int minutes, int seconds) {
    int totalSeconds = normalizeToSeconds(hours, minutes, seconds);
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      remainingSeconds: totalSeconds,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void toggleTaskTimer(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final task = _tasks[index];

    if (task.isRunning) {
      task.timer?.cancel();
      task.isRunning = false;
    } else {
      if (task.remainingSeconds <= 0) return;

      task.isRunning = true;
      task.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (task.remainingSeconds > 0) {
          task.remainingSeconds--;
          notifyListeners();
        } else {
          task.timer?.cancel();
          task.isRunning = false;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].timer?.cancel();
      _tasks.removeAt(index);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (var task in _tasks) {
      task.timer?.cancel();
    }
    super.dispose();
  }
}