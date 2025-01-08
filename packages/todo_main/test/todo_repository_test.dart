import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_main/model/todo.dart';
import 'package:todo_main/repositories/todo_repository.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class FakeTodoRepository implements TodoRepository {
  final List<Todo> _todos = [];

  @override
  Future<List<Todo>> getTodos() async {
    return _todos;
  }

  @override
  Future<Todo> getTodoById(String id) async {
    final todo = _todos.firstWhere(
      (todo) => todo.id == id,
      orElse: () => throw Exception('Todo not found'),
    );
    return todo;
  }

  @override
  Future<Todo> createTodo(String title, String? description) async {
    final now = DateTime.now();
    final todo = Todo(
      id: now.toIso8601String(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: now,
      completedAt: null,
    );
    _todos.add(todo);
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) {
      throw Exception('Todo not found');
    }
    _todos[index] = todo;
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Todo not found');
    }
    _todos.removeAt(index);
  }
}

void main() {
  group('TodoRepository', () {
    late FakeTodoRepository repository;

    setUp(() {
      repository = FakeTodoRepository();
    });

    test('getTodos returns empty list initially', () async {
      final todos = await repository.getTodos();
      expect(todos, isEmpty);
    });

    group('createTodo', () {
      test('creates todo with title only', () async {
        final todo = await repository.createTodo('Test Todo', null);

        expect(todo.title, equals('Test Todo'));
        expect(todo.description, isNull);
        expect(todo.isCompleted, isFalse);
        expect(todo.completedAt, isNull);
        expect(todo.id, isNotEmpty);
        expect(todo.createdAt, isNotNull);
      });

      test('creates todo with title and description', () async {
        final todo =
            await repository.createTodo('Test Todo', 'Test Description');

        expect(todo.title, equals('Test Todo'));
        expect(todo.description, equals('Test Description'));
        expect(todo.isCompleted, isFalse);
        expect(todo.completedAt, isNull);
        expect(todo.id, isNotEmpty);
        expect(todo.createdAt, isNotNull);
      });

      test('adds todo to repository', () async {
        final created = await repository.createTodo('Test Todo', null);
        final todos = await repository.getTodos();

        expect(todos, contains(created));
        expect(todos.length, equals(1));
      });
    });

    group('getTodoById', () {
      test('returns correct todo', () async {
        final created = await repository.createTodo('Test Todo', null);
        final fetched = await repository.getTodoById(created.id);

        expect(fetched, equals(created));
      });

      test('throws exception when todo not found', () {
        expect(
          () => repository.getTodoById('non-existent-id'),
          throwsException,
        );
      });
    });

    group('updateTodo', () {
      test('updates existing todo', () async {
        final created = await repository.createTodo('Test Todo', null);
        final now = DateTime.now();

        final updated = await repository.updateTodo(
          Todo(
            id: created.id,
            title: 'Updated Todo',
            description: 'Updated Description',
            isCompleted: true,
            createdAt: created.createdAt,
            completedAt: now,
          ),
        );

        expect(updated.title, equals('Updated Todo'));
        expect(updated.description, equals('Updated Description'));
        expect(updated.isCompleted, isTrue);
        expect(updated.completedAt, equals(now));
        expect(updated.createdAt, equals(created.createdAt));

        final fetched = await repository.getTodoById(created.id);
        expect(fetched, equals(updated));
      });

      test('throws exception when todo not found', () {
        final now = DateTime.now();
        expect(
          () => repository.updateTodo(
            Todo(
              id: 'non-existent-id',
              title: 'Test',
              description: null,
              isCompleted: false,
              createdAt: now,
              completedAt: null,
            ),
          ),
          throwsException,
        );
      });
    });

    group('deleteTodo', () {
      test('deletes existing todo', () async {
        final created = await repository.createTodo('Test Todo', null);
        await repository.deleteTodo(created.id);

        final todos = await repository.getTodos();
        expect(todos, isEmpty);

        expect(
          () => repository.getTodoById(created.id),
          throwsException,
        );
      });

      test('throws exception when todo not found', () {
        expect(
          () => repository.deleteTodo('non-existent-id'),
          throwsException,
        );
      });
    });

    test('copyWith maintains immutability', () async {
      final original =
          await repository.createTodo('Original Todo', 'Description');
      final now = DateTime.now();

      final updated = original.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
        isCompleted: true,
        completedAt: now,
      );

      // Verify original is unchanged
      expect(original.title, equals('Original Todo'));
      expect(original.description, equals('Description'));
      expect(original.isCompleted, isFalse);
      expect(original.completedAt, isNull);

      // Verify updated has new values
      expect(updated.title, equals('Updated Title'));
      expect(updated.description, equals('Updated Description'));
      expect(updated.isCompleted, isTrue);
      expect(updated.completedAt, equals(now));

      // Verify unchanged values
      expect(updated.id, equals(original.id));
      expect(updated.createdAt, equals(original.createdAt));
    });
  });
}
