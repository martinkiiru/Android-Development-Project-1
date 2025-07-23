// ignore_for_file: depend_on_referenced_packages, avoid_print, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;

  List<Todo> get completedTodos => _todos.where((todo) => todo.isCompleted).toList();
  List<Todo> get pendingTodos => _todos.where((todo) => !todo.isCompleted).toList();

  // Load todos from storage
  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await StorageService.loadTodos();
    } catch (e) {
      print('Error loading todos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new todo
  Future<void> addTodo(String title, {String description = ''}) async {
    if (title.trim().isEmpty) return;

    final todo = Todo(
      id: Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _todos.insert(0, todo);
    await _saveTodos();
    notifyListeners();
  }

  // Update todo
  Future<void> updateTodo(String id, {String? title, String? description, bool? isCompleted}) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    _todos[index] = _todos[index].copyWith(
      title: title,
      description: description,
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );

    await _saveTodos();
    notifyListeners();
  }

  // Delete todo
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await _saveTodos();
    notifyListeners();
  }

  // Toggle todo completion
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    _todos[index] = _todos[index].copyWith(
      isCompleted: !_todos[index].isCompleted,
      updatedAt: DateTime.now(),
    );

    await _saveTodos();
    notifyListeners();
  }

  // Clear completed todos
  Future<void> clearCompleted() async {
    _todos.removeWhere((todo) => todo.isCompleted);
    await _saveTodos();
    notifyListeners();
  }

  // Save todos to storage
  Future<void> _saveTodos() async {
    await StorageService.saveTodos(_todos);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo Home')),
      body: const Center(child: Text('Welcome to the Todo App!')),
    );
  }
}