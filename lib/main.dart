import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'models/task_model.dart';
import 'screens/task_list_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Add this line



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kato Tasks App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginScreen()
          : const TaskListScreen(),

    );
  }
}
