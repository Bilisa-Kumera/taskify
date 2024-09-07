import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task/main.dart';
import 'package:task/model/task_model.dart';
import 'package:task/provider/task_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? _title;
  String? _description;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _isCompleted = widget.task!.isCompleted;
    }

    _initializeNotifications();
  }

  void _initializeNotifications() {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _pickDueTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

Future<void> _scheduleNotification(Task task) async {
  if (_dueDate != null) {
    final taskDateTime = DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime?.hour ?? 0,
      _dueTime?.minute ?? 0,
    );

    if (taskDateTime.isAfter(DateTime.now())) {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        taskDateTime,
        tz.local, // This uses the local timezone
      );

      final int notificationId = task.id ?? DateTime.now().millisecondsSinceEpoch % 2147483647;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_channel',
        'Task Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Task Reminder',
        'Reminder for task: ${task.title}',
        scheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  fillColor: Colors.deepPurple.shade50,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  border: OutlineInputBorder(),
                  fillColor: Colors.deepPurple.shade50,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _dueDate == null
                        ? 'Pick a Due Date'
                        : 'Due Date: ${DateFormat.yMMMd().format(_dueDate!)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _pickDueDate(context),
                    child: Text('Select Date'),
                    style: TextButton.styleFrom(primary: Colors.deepPurple),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _dueTime == null
                        ? 'Pick a Due Time'
                        : 'Due Time: ${_dueTime!.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => _pickDueTime(context),
                    child: Text('Select Time'),
                    style: TextButton.styleFrom(primary: Colors.deepPurple),
                  ),
                ],
              ),
              DropdownButtonFormField<bool>(
                value: _isCompleted,
                items: [
                  DropdownMenuItem(
                    child: Text('Incomplete'),
                    value: false,
                  ),
                  DropdownMenuItem(
                    child: Text('Completed'),
                    value: true,
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
                decoration: InputDecoration(labelText: 'Task Status'),
              ),
              SizedBox(height: 20),
             ElevatedButton(
  onPressed: () {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTask = Task(
        id: widget.task?.id,
        title: _title!,
        description: _description!,
        dueDate: _dueDate ?? DateTime.now(),
        isCompleted: _isCompleted,
      );

      if (widget.task == null) {
        Provider.of<TaskProvider>(context, listen: false)
            .addTask(newTask);
      } else {
        Provider.of<TaskProvider>(context, listen: false)
            .updateTask(newTask);
      }

      if (_dueDate != null) {
        _scheduleNotification(newTask);
      }

      Navigator.pop(context);
    }
  },
  child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
  style: ElevatedButton.styleFrom(
    primary: Colors.deepPurple,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    textStyle: TextStyle(fontSize: 16),
  ),
)

            ],
          ),
        ),
      ),
    );
  }
}
