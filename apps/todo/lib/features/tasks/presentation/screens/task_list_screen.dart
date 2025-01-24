import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/features/tasks/providers/task_providers.dart';
import 'package:todo_core/model/task.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context, ref),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (tasks) => ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListItem(task: task);
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAdd: (task) {
          ref.read(tasksProvider.notifier).addTask(task);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class TaskListItem extends ConsumerWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      onDismissed: (_) {
        ref.read(tasksProvider.notifier).deleteTask(task.id);
      },
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (value != null) {
              ref.read(tasksProvider.notifier).updateTask(
                    task.copyWith(isCompleted: value),
                  );
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.priority != null)
              Icon(
                Icons.priority_high,
                color: _getPriorityColor(task.priority!),
              ),
            if (task.dueDate != null)
              Text(
                _formatDate(task.dueDate!),
                style: TextStyle(
                  color: _isOverdue(task.dueDate!) ? Colors.red : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }
}

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onAdd;

  const AddTaskDialog({super.key, required this.onAdd});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  int? _priority;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              children: [
                const Text('Priority: '),
                DropdownButton<int>(
                  value: _priority,
                  items: [1, 2, 3].map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text('P$priority'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _priority = value),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                setState(() => _dueDate = date);
              },
              child: Text(_dueDate == null
                  ? 'Set Due Date'
                  : 'Due: ${_formatDate(_dueDate!)}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final task = Task.create(
              title: _titleController.text,
              description: _descriptionController.text,
              dueDate: _dueDate,
              priority: _priority,
            );
            widget.onAdd(task);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
