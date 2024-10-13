import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoT extends StatefulWidget {
  const TodoT({super.key});

  @override
  State<TodoT> createState() => _TodoState();
}

class _TodoState extends State<TodoT> {
  TextEditingController addController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> tasks = [];
  String todoistApiKey = '2fa06832ebd7fb8722ce876fb536009f56af1f6b';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.todoist.com/rest/v2/tasks"),
        headers: {
          'Authorization': 'Bearer $todoistApiKey',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          tasks = data.map((task) => task as Map<String, dynamic>).toList();
        });
      } else {
        _showAlertDialog("Error", "Failed to fetch tasks");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to load tasks: $e");
    }
  }

  Future<void> postData(String taskName, String description) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.todoist.com/rest/v2/tasks'),
        headers: {
          'Authorization': 'Bearer $todoistApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': taskName,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchTasks();
        addController.clear();
        descriptionController.clear();
        Navigator.of(context).pop();
      } else {
        _showAlertDialog("Error", "Failed to add task");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to add task: $e");
    }
  }

  Future<void> updateData(String id, String taskName, String description) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.todoist.com/rest/v2/tasks/$id'),
        headers: {
          'Authorization': 'Bearer $todoistApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': taskName,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        fetchTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully')),
        );
        addController.clear();
        descriptionController.clear();
      } else {
        _showAlertDialog("Error", "Failed to update task: ${response.body}");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to update task: $e");
    }
  }

  Future<void> deleteData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://api.todoist.com/rest/v2/tasks/$id'),
        headers: {
          'Authorization': 'Bearer $todoistApiKey',
        },
      );
      if (response.statusCode == 204) {
        fetchTasks();
      } else {
        _showAlertDialog("Error", "Failed to delete task");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to delete task: $e");
    }
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(content, style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openUpdateDialog(String id, String taskName, String description) {
    addController.text = taskName;
    descriptionController.text = description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Update Task', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Task Name",
                  labelStyle: TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Task Description",
                  labelStyle: TextStyle(color: Colors.white70),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (addController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  updateData(id, addController.text, descriptionController.text);
                  Navigator.of(context).pop();
                } else {
                  _showAlertDialog("Error", "Please fill all fields");
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Center(child:  Text("Get It Done", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.grey[850],
              child: ListTile(
                title: Text(
                  task['content'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(task['description'] ?? "", style: const TextStyle(color: Colors.white70)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () {
                        _openUpdateDialog(
                          task['id'].toString(),
                          task['content'],
                          task['description'] ?? '',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        deleteData(task['id'].toString());
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddTaskDialog();
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[200],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.task, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.description, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    if (addController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      postData(addController.text, descriptionController.text);
                    } else {
                      _showAlertDialog("Error", "Please fill all fields");
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
