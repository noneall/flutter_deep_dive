import 'package:todo_domain/model/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> getTodoById(String id);
  Future<Todo> createTodo(String title, String? description);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}