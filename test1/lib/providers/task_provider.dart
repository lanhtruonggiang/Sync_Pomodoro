import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  StreamSubscription<User?>? _authSubscription;
  Timer? _uiTicker;
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  TaskProvider() {
    _initAuthAndDataSync();
  }

  void _initAuthAndDataSync() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      _currentUser = user;
      _tasksSubscription?.cancel();

      if (user != null) {
        // Lắng nghe Stream Firestore Realtime
        _tasksSubscription = _firestoreService.streamTasks(user.uid).listen((newTasks) {
          _tasks = newTasks;
          _syncLocalCalculations();
          notifyListeners();
        });
        _startLocalUiTicker();
      } else {
        _tasks = [];
        _stopLocalUiTicker();
        notifyListeners();
      }
    });
  }

  // Local Ticker: Đếm ngược mượt mà ở Client không gửi Write Request lên Firestore
  void _startLocalUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncLocalCalculations();
    });
  }

  void _stopLocalUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = null;
  }

  void _syncLocalCalculations() {
    final now = DateTime.now();
    bool hasChanged = false;

    for (var task in _tasks) {
      if (task.isRunning && task.targetEndTime != null) {
        final diff = task.targetEndTime!.difference(now).inSeconds;
        if (diff > 0) {
          if (task.remainingSeconds != diff) {
            task.remainingSeconds = diff;
            hasChanged = true;
          }
        } else {
          task.remainingSeconds = 0;
          task.isRunning = false;
          hasChanged = true;
        }
      }
    }
    if (hasChanged) notifyListeners();
  }

  bool isTaskNameDuplicate(String name) {
    return _tasks.any(
      (task) => task.name.trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }

  int normalizeToSeconds(int hours, int minutes, int seconds) {
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  // --- FIRESTORE ACTIONS ---
  Future<void> addTask(String name, int hours, int minutes, int seconds) async {
    if (_currentUser == null) return;
    int total = normalizeToSeconds(hours, minutes, seconds);
    await _firestoreService.addTask(_currentUser!.uid, name, total);
  }

  Future<void> toggleTaskTimer(String id) async {
    if (_currentUser == null) return;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final task = _tasks[index];
    if (task.isRunning) {
      final now = DateTime.now();
      final diff = task.targetEndTime?.difference(now).inSeconds ?? task.remainingSeconds;
      await _firestoreService.updateTimerState(_currentUser!.uid, task, false, diff > 0 ? diff : 0, null);
    } else {
      if (task.remainingSeconds <= 0) return;
      final targetEnd = DateTime.now().add(Duration(seconds: task.remainingSeconds));
      await _firestoreService.updateTimerState(_currentUser!.uid, task, true, task.remainingSeconds, targetEnd);
    }
  }

  Future<void> resetTaskTimer(String id) async {
    if (_currentUser == null) return;
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    await _firestoreService.resetTask(_currentUser!.uid, _tasks[index]);
  }

  Future<void> deleteTask(String id) async {
    if (_currentUser == null) return;
    await _firestoreService.deleteTask(_currentUser!.uid, id);
  }

  Future<void> sendPasswordlessLink(String email) async {
    await _authService.sendPasswordlessLink(email);
  }

  Future<void> completeSignIn(String email, String link) async {
    await _authService.completeSignInWithEmailLink(email, link);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _authSubscription?.cancel();
    _stopLocalUiTicker();
    super.dispose();
  }
}