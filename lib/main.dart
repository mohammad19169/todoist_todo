import 'package:flutter/material.dart';
import 'package:todoist_todo/Screens/todoapp.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:TodoT(),
    );
  }
}