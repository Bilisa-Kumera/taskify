import 'package:flutter/material.dart';
import 'package:task/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:task/utils/app_router.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
    WidgetsFlutterBinding.ensureInitialized();
tz.initializeTimeZones();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskify',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}
