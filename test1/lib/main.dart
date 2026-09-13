import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _taskProvider = TaskProvider();
    
    // Kiểm tra & Xử lý Magic Email Link khi ứng dụng vừa mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIncomingEmailLink();
    });
  }

  void _checkIncomingEmailLink() async {
    final currentUri = Uri.base;
    if (currentUri.toString().contains('apiKey=')) {
      // Nhận email từ local storage hoặc prompt người dùng nhập lại để xác minh
      // _taskProvider.completeSignIn(email, currentUri.toString());
    }
  }

  @override
  void dispose() {
    _taskProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _taskProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pomodoro Multi-Timer Cloud',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}