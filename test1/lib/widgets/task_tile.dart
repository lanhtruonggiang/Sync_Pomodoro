import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final int index;

  const TaskTile({
    super.key,
    required this.task,
    required this.index,
  });

  static const List<Color> _barColors = [
    Color(0xFFD4B06A), // Vàng
    Color(0xFF8DBE7A), // Xanh lá
    Color(0xFFC7786B), // Đỏ
    Color(0xFF64B3B4), // Xanh dương
  ];

  @override
  Widget build(BuildContext context) {
    final double progress = task.initialTotalSeconds > 0
        ? (task.remainingSeconds / task.initialTotalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final Color barColor = _barColors[index % _barColors.length];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // 1. Progress Bar đếm ngược
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  heightFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.75),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Nội dung Text và Nút bấm
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${task.name} : ${task.formattedTime}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Action Buttons Compact Style
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                    icon: const Icon(Icons.refresh, size: 20, color: Colors.black),
                    tooltip: 'Reset',
                    onPressed: () {
                      context.read<TaskProvider>().resetTaskTimer(task.id);
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                    icon: Icon(
                      task.isRunning ? Icons.pause : Icons.play_arrow,
                      size: 22,
                      color: Colors.black,
                    ),
                    tooltip: task.isRunning ? 'Pause' : 'Play',
                    onPressed: () {
                      context.read<TaskProvider>().toggleTaskTimer(task.id);
                    },
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                    icon: const Icon(Icons.close, size: 20, color: Colors.black),
                    tooltip: 'Delete',
                    onPressed: () {
                      context.read<TaskProvider>().deleteTask(task.id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}