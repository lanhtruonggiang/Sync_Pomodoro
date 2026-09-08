import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/new_task_dialog.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NewTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F9),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : 450,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 12,
              vertical: 16,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              children: [
                // Header Title
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'POMODORO MULTI-TIMER',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Danh sách Task (Responsive Layout)
                Expanded(
                  child: Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      if (taskProvider.tasks.isEmpty) {
                        return const Center(
                          child: Text(
                            'Chưa có task nào.\nBấm nút + để tạo mới!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Nếu là màn hình rộng (PC) -> Grid 2 cột
                          if (constraints.maxWidth > 600) {
                            return GridView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 68,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: taskProvider.tasks.length,
                              itemBuilder: (context, index) {
                                final task = taskProvider.tasks[index];
                                return TaskTile(
                                  key: ValueKey(task.id),
                                  task: task,
                                  index: index,
                                );
                              },
                            );
                          }

                          // Màn hình Mobile (iOS) -> Danh sách 1 cột
                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: taskProvider.tasks.length,
                            itemBuilder: (context, index) {
                              final task = taskProvider.tasks[index];
                              return TaskTile(
                                key: ValueKey(task.id),
                                task: task,
                                index: index,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Nút bấm thêm Task
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => _showAddTaskDialog(context),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}