import 'package:todo_core/models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task> getTask(String id);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class TaskRepositoryImpl implements TaskRepository {
  final Map<String, Task> _tasks = {};

  @override
  Future<List<Task>> getTasks() async {
    return _tasks.values.toList();
  }

  @override
  Future<Task> getTask(String id) async {
    final task = _tasks[id];
    if (task == null) {
      throw Exception('Task not found');
    }
    return task;
  }

  @override
  Future<void> createTask(Task task) async {
    _tasks[task.id] = task;
  }

  @override
  Future<void> updateTask(Task task) async {
    if (!_tasks.containsKey(task.id)) {
      throw Exception('Task not found');
    }
    _tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }
}
