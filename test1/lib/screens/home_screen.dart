import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/new_task_dialog.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Đăng nhập Email Link'),
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Nhập email của bạn...',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _emailController.text.trim();
              if (email.isNotEmpty) {
                await context.read<TaskProvider>().sendPasswordlessLink(email);
                if (mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã gửi Magic Link! Vui lòng kiểm tra Email.')),
                  );
                }
              }
            },
            child: const Text('Gửi Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final user = taskProvider.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F9),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 800 : 450),
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
                // Top Header với Nút Auth Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'POMODORO MULTI-TIMER',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    user == null
                        ? TextButton.icon(
                            onPressed: () => _showAuthDialog(context),
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text('Đăng nhập'),
                          )
                        : IconButton(
                            tooltip: 'Đăng xuất (${user.email})',
                            icon: const Icon(Icons.logout, color: Colors.red),
                            onPressed: () => context.read<TaskProvider>().signOut(),
                          ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                // Nội dung Danh sách Tasks
                Expanded(
                  child: user == null
                      ? const Center(
                          child: Text(
                            'Vui lòng đăng nhập để đồng bộ danh sách Task trên Cloud.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      : taskProvider.tasks.isEmpty
                          ? const Center(
                              child: Text(
                                'Chưa có task nào.\nBấm nút + để tạo mới!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 600) {
                                  return GridView.builder(
                                    padding: const EdgeInsets.only(top: 8),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            ),
                ),
                const SizedBox(height: 12),

                // Nút Thêm Task
                if (user != null)
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const NewTaskDialog(),
                        );
                      },
                      child: const Icon(Icons.add, color: Colors.black, size: 28),
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