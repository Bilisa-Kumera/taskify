import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task/db/db_helper.dart';
import 'package:task/model/task_model.dart';
import 'package:http/http.dart' as http;

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  String? _quote;

  List<Task> get tasks => _tasks;
  String? get quote => _quote;

  Future<void> fetchTasks() async {
    _tasks = await DatabaseHelper().tasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper().insertTask(task);
    fetchTasks(); 
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper().updateTask(task);
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    fetchTasks(); 
  }

  Future<void> removeTask(Task task) async {
    await DatabaseHelper().deleteTask(task.id!); 
    fetchTasks(); 
  }

  Future<void> completeTask(Task task) async {
    task.isCompleted = true;
    await DatabaseHelper().updateTask(task);
    fetchTasks(); 
  }

  Future<void> fetchQuote() async {
    final url = Uri.parse('https://api.quotable.io/random');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _quote = '${jsonResponse['content']} — ${jsonResponse['author']}';
        notifyListeners();
      } else {
        print('Failed to load quote. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quote: $e');
    }
  }
}
