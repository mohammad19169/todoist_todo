import 'package:flutter/material.dart';
import 'package:todoist_todo/Screens/splash.dart';
import 'package:todoist_todo/Screens/todoapp.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Splash(),
    );
  }
}