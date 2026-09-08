import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/new_task_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 380,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = provider.tasks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${task.name} : ${task.formattedTime}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  task.isRunning
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 28,
                                ),
                                onPressed: () =>
                                    provider.toggleTaskTimer(task.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 28),
                                onPressed: () => provider.deleteTask(task.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  context.read<TaskProvider>().resetTaskTimer(
                                    task.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const NewTaskDialog(),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, size: 32),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
