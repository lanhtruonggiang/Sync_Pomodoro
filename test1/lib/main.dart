import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLifecycleListener _lifecycleListener;
  late final TaskProvider _taskProvider;

  @override
  void initState() {
    super.initState();
    _taskProvider = TaskProvider();

    // Lắng nghe sự kiện Lifecycle trên Safari Web & Mobile
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        // Đồng bộ tính lại thời gian còn lại khi quay lại ứng dụng
        _taskProvider.recalculateOnResume();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _taskProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _taskProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pomodoro Local Web',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}