import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({super.key});

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hhController = TextEditingController(text: "00");
  final _mmController = TextEditingController(text: "00");
  final _ssController = TextEditingController(text: "00");

  @override
  void dispose() {
    _nameController.dispose();
    _hhController.dispose();
    _mmController.dispose();
    _ssController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final hh = int.tryParse(_hhController.text) ?? 0;
    final mm = int.tryParse(_mmController.text) ?? 0;
    final ss = int.tryParse(_ssController.text) ?? 0;

    if (hh == 0 && mm == 0 && ss == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thời gian phải lớn hơn 00:00:00')),
      );
      return;
    }

    Provider.of<TaskProvider>(context, listen: false)
        .addTask(name, hh, mm, ss);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New task',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Tên không được để trống';
                    }
                    if (provider.isTaskNameDuplicate(val)) {
                      return 'Tên Task đã tồn tại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Time: ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Expanded(child: _buildTimeInput(_hhController, 'HH')),
                    const SizedBox(width: 4),
                    Expanded(child: _buildTimeInput(_mmController, 'MM')),
                    const SizedBox(width: 4),
                    Expanded(child: _buildTimeInput(_ssController, 'SS')),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submitData,
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.black, fontSize: 16),
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

  Widget _buildTimeInput(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      // Bật bàn phím số thuần trên iOS / Safari
      keyboardType: const TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      textAlign: TextAlign.center,
      onChanged: (value) {
        String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (clean.length > 2) {
          clean = clean.substring(clean.length - 2);
        }
        if (clean != value) {
          controller.value = TextEditingValue(
            text: clean,
            selection: TextSelection.collapsed(offset: clean.length),
          );
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}