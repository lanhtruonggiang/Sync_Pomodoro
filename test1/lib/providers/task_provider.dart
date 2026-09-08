import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  static const String _storageKey = 'local_tasks_data';
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  TaskProvider() {
    _loadTasksFromStorage();
  }

  // --- LOCAL STORAGE LOGIC ---
  Future<void> _saveTasksToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = _tasks
        .map((task) => task.toJson())
        .toList();
    await prefs.setString(_storageKey, jsonEncode(jsonData));
  }

  Future<void> _loadTasksFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_storageKey);

    if (rawData != null && rawData.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(rawData);
        _tasks = jsonList.map((item) => TaskModel.fromJson(item)).toList();

        _restoreRunningTimers();
      } catch (e) {
        _tasks = [];
      }
    }
    notifyListeners();
  }

  // Khôi phục & Đồng bộ lại thời gian thực tế
  void recalculateOnResume() {
    _restoreRunningTimers();
  }

  void _restoreRunningTimers() {
    final now = DateTime.now();

    for (var task in _tasks) {
      if (task.isRunning && task.targetEndTime != null) {
        final diffSeconds = task.targetEndTime!.difference(now).inSeconds;

        if (diffSeconds > 0) {
          task.remainingSeconds = diffSeconds;
          _startTimerInstance(task);
        } else {
          // Task đã kết thúc trong lúc đóng/ẩn app
          task.remainingSeconds = 0;
          task.isRunning = false;
          task.targetEndTime = null;
          task.timer?.cancel();
          task.timer = null;
        }
      }
    }
    _saveTasksToStorage();
    notifyListeners();
  }

  // --- HELPER LOGIC ---
  bool isTaskNameDuplicate(String name) {
    return _tasks.any(
      (task) => task.name.trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }

  int normalizeToSeconds(int hours, int minutes, int seconds) {
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  // --- TASK MANAGEMENT LOGIC ---
  void addTask(String name, int hours, int minutes, int seconds) {
    int totalSeconds = normalizeToSeconds(hours, minutes, seconds);
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      initialTotalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
    );
    _tasks.add(newTask);
    _saveTasksToStorage();
    notifyListeners();
  }

  void toggleTaskTimer(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final task = _tasks[index];

    if (task.isRunning) {
      task.timer?.cancel();
      task.timer = null;
      if (task.targetEndTime != null) {
        final now = DateTime.now();
        final diff = task.targetEndTime!.difference(now).inSeconds;
        task.remainingSeconds = diff > 0 ? diff : 0;
      }
      task.isRunning = false;
      task.targetEndTime = null;
    } else {
      if (task.remainingSeconds <= 0) return;

      task.isRunning = true;
      task.targetEndTime = DateTime.now().add(
        Duration(seconds: task.remainingSeconds),
      );
      _startTimerInstance(task);
    }

    _saveTasksToStorage();
    notifyListeners();
  }

  void resetTaskTimer(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final task = _tasks[index];

    task.timer?.cancel();
    task.isRunning = false;
    task.targetEndTime = null;
    task.remainingSeconds = task.initialTotalSeconds;

    _saveTasksToStorage();
    notifyListeners();
  }

  void _startTimerInstance(TaskModel task) {
    task.timer?.cancel();
    task.timer = null;

    task.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (task.targetEndTime == null || !task.isRunning) {
        timer.cancel();
        task.timer = null;
        return;
      }

      if (task.remainingSeconds > 1) {
        task.remainingSeconds--;
        notifyListeners();
      } else {
        task.remainingSeconds = 0;
        task.isRunning = false;
        task.targetEndTime = null;
        timer.cancel();
        task.timer = null;
        _saveTasksToStorage();
        notifyListeners();
      }
    });
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].timer?.cancel();
      _tasks.removeAt(index);
      _saveTasksToStorage();
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