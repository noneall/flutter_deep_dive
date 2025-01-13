// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo/main.dart';

void main() {
  group('Todo App Widget Tests', () {
    testWidgets('App starts with no todo items', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const TodoApp());

      // Verify that there are no todo items
      expect(find.byType(ListTile), findsNothing);

      // Verify that the input field exists
      expect(find.byType(TextField), findsOneWidget);

      // Verify that the add button exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Can add todo item', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());

      // Enter text in the input field
      await tester.enterText(find.byType(TextField), 'New Todo Item');

      // Tap the add button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify that the todo item was added
      expect(find.text('New Todo Item'), findsOneWidget);

      // Verify that the input field is cleared
      expect(find.widgetWithText(TextField, 'New Todo Item'), findsNothing);
    });

    testWidgets('Can toggle todo item checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());

      // Add a todo item
      await tester.enterText(find.byType(TextField), 'Test Todo');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify initial state (unchecked)
      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, false);

      // Tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verify the checkbox is checked
      final Checkbox updatedCheckbox = tester.widget(find.byType(Checkbox));
      expect(updatedCheckbox.value, true);

      // Verify the text is struck through
      final Text todoText = tester.widget(find.text('Test Todo'));
      expect(
        todoText.style?.decoration,
        equals(TextDecoration.lineThrough),
      );
    });

    testWidgets('Can delete todo item', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());

      // Add a todo item
      await tester.enterText(find.byType(TextField), 'Delete Me');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify the item exists
      expect(find.text('Delete Me'), findsOneWidget);

      // Find and tap the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Verify the item is deleted
      expect(find.text('Delete Me'), findsNothing);
    });

    testWidgets('Cannot add empty todo item', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());

      // Try to add empty todo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify no item was added
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
