import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String uid) {
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // Stream Realtime nhận cập nhật từ Cloud Firestore
  Stream<List<TaskModel>> streamTasks(String uid) {
    return _userTasksRef(uid).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    });
  }

  // Tạo Task mới
  Future<void> addTask(String uid, String name, int totalSeconds) async {
    await _userTasksRef(uid).add({
      'name': name.trim(),
      'initialTotalSeconds': totalSeconds,
      'remainingSeconds': totalSeconds,
      'isRunning': false,
      'targetEndTime': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Cập nhật trạng thái Play / Pause
  Future<void> updateTimerState(String uid, TaskModel task, bool isRunning, int remainingSeconds, DateTime? targetEndTime) async {
    await _userTasksRef(uid).doc(task.id).update({
      'isRunning': isRunning,
      'remainingSeconds': remainingSeconds,
      'targetEndTime': targetEndTime != null ? Timestamp.fromDate(targetEndTime) : null,
    });
  }

  // Reset Task (Đồng bộ khôi phục về ban đầu cho mọi thiết bị)
  Future<void> resetTask(String uid, TaskModel task) async {
    await _userTasksRef(uid).doc(task.id).update({
      'isRunning': false,
      'remainingSeconds': task.initialTotalSeconds,
      'targetEndTime': null,
    });
  }

  // Xóa Task
  Future<void> deleteTask(String uid, String taskId) async {
    await _userTasksRef(uid).doc(taskId).delete();
  }
}