import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:task/model/task_model.dart';
import 'package:task/provider/task_provider.dart';
import 'package:task/screens/add_edit_screen.dart';
import 'package:task/screens/completed_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.fetchQuote();
    taskProvider.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskify', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
     drawer: Drawer(
  child: Container(
    color: Colors.deepPurple,
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.task, size: 40, color: Colors.deepPurple),
              ),
              SizedBox(height: 16),
              Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _buildDrawerItem(Icons.home, 'Home', () {
          Navigator.pop(context);
        }),
        _buildDrawerItem(Icons.check, 'Completed Tasks', () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/completed_tasks');
        }),
        _buildDrawerItem(Icons.settings, 'Settings', () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/settings');
        }),
      ],
    ),
  ),
),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding:  EdgeInsets.only(top:8.0, left: 18),
            child: Text('Quote of the day', style: TextStyle(fontSize: 18),),
          ),
          // Motivational Quote Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return taskProvider.quote != null
                    ? Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '"${taskProvider.quote}"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return taskProvider.tasks.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: taskProvider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.tasks[index];
                          
                          return Dismissible(
                            key: Key(task.id.toString()), 
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              taskProvider.removeTask(task);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _showTaskOptionsDialog(context, taskProvider, task);
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task.description),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Due: ${DateFormat.yMMMd().format(task.dueDate)}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  trailing: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (value) {
                                      task.isCompleted = value ?? false;
                                      taskProvider.notifyListeners();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('No tasks available.', style: TextStyle(fontSize: 18, color: Colors.grey[600])));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
void _showTaskOptionsDialog(
    BuildContext context, TaskProvider taskProvider, Task task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Task Options"),
        content: Text("Choose an action for the task '${task.title}'"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Mark the task as complete
              taskProvider.completeTask(task);
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("Finish"),
          ),
          TextButton(
            onPressed: () {
              // Navigate to AddEditTaskScreen for editing the task
              Navigator.of(context).pop(); // Close the dialog first
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditTaskScreen(task: task),
                ),
              );
            },
            child: const Text("Edit"),
          ),
        ],
      );
    },
  );
}


  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: onTap,
    );
  }
}
