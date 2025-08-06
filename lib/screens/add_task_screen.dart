import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';

class AddTaskScreen extends StatelessWidget {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final taskBox = Hive.box<Task>('tasks');

    return Scaffold(
      appBar: AppBar(title: Text("Add Task")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
              validator: (value) => value == null || value.isEmpty ? "Enter title" : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  taskBox.add(Task(
                    title: _titleController.text,
                    description: _descController.text,
                    dueDate: DateTime.now(),
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text("Add Task"),
            )
          ]),
        ),
      ),
    );
  }
}
