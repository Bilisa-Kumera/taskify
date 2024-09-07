import 'package:flutter/material.dart';
import 'package:task/screens/add_edit_screen.dart';
import 'package:task/screens/home_screen.dart';
import 'package:task/screens/completed_task_screen.dart';
import 'package:task/screens/settings.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/completed_tasks':
        return MaterialPageRoute(builder: (_) =>  CompletedTasksScreen());
        case '/add_task':
        return MaterialPageRoute(builder: (_) =>  const AddEditTaskScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
