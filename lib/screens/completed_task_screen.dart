import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task/provider/task_provider.dart';

class CompletedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final completedTasks = taskProvider.tasks.where((task) => task.isCompleted).toList();

          return completedTasks.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    final task = completedTasks[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.green[50],
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description, style: TextStyle(color: Colors.green[700])),
                            SizedBox(height: 4),
                            Text(
                              'Completed on: ${DateFormat.yMMMd().format(task.dueDate)}',
                              style: TextStyle(color: Colors.green[600], fontSize: 14),
                            ),
                          ],
                        ),
                        leading: Icon(Icons.check_circle, color: Colors.green[800], size: 36),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    'No completed tasks.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                );
        },
      ),
    );
  }
}
