import 'package:flutter/material.dart';
import 'package:todoist_todo/Screens/todoapp.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoT(),
    );
  }
}