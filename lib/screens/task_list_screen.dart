import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kato_tasks_app/models/task_model.dart';
import 'package:kato_tasks_app/screens/edit_task_screen.dart';
import 'package:kato_tasks_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  void deleteTask(int index) {
    final box = Hive.box<Task>('tasks');
    box.deleteAt(index);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void showEmail(BuildContext context, String? email) {
    if (email != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged in as: $email")),
      );
    }
  }

  bool isDueToday(DateTime dueDate) {
    final now = DateTime.now();
    return now.year == dueDate.year &&
        now.month == dueDate.month &&
        now.day == dueDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        toolbarHeight: 90,
        leading: GestureDetector(
          onTap: () => showEmail(context, user?.email),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Text(
                        user?.displayName != null
                            ? user!.displayName![0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )
                    : null,
              ),
            ),
          ),
        ),
        title: const Text(
          "Kato Task Manager",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Task>('tasks').listenable(),
          builder: (context, Box<Task> box, _) {
            if (box.isEmpty) {
              return const Center(
                child: Text(
                  "No tasks yet!",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 80),
              itemCount: box.length,
              itemBuilder: (context, index) {
                final task = box.getAt(index);
                if (task == null) return const SizedBox();

                return Dismissible(
                  key: Key(task.key.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => deleteTask(index),
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(
                        task.isComplete
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.isComplete ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          decoration: task.isComplete
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(task.description),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "${task.dueDate.toLocal().toString().split(' ')[0]}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 10),
                              if (isDueToday(task.dueDate))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Due Today",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task.isComplete,
                        onChanged: (val) {
                          setState(() {
                            task.isComplete = val!;
                            task.save();
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskScreen(task: task),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add),
        label: const Text("New Task"),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditTaskScreen()),
        ),
      ),
    );
  }
}
