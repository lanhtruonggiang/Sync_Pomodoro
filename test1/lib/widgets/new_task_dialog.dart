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

    Provider.of<TaskProvider>(context, listen: false).addTask(name, hh, mm, ss);
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
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 320,
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                decoration: const InputDecoration(
                  labelText: 'name',
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
                  const Text('time ', style: TextStyle(fontSize: 16)),
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
                    'ok',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      // Bỏ LengthLimiting và FilteringTextInputFormatter tại đây
      onChanged: (value) {
        // Chỉ giữ lại tối đa 2 chữ số
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
