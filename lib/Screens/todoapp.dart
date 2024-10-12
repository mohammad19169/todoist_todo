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
  String selectedPriority = '1'; // Default priority (Medium)
  List<Map<String, dynamic>> tasks = [];
  String todoistApiKey = '346b45e26a52908b1625de738804690e19e11fba'; // Replace with your API key
  bool sortAscending = true; // Tracks sorting order (true: Low to High, false: High to Low)
  String filterPriority = 'All'; // For filtering tasks by priority

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch tasks from Todoist (v2 API)
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
          _sortTasks();
          _filterTasks();
        });
      } else {
        _showAlertDialog("Error", "Failed to fetch tasks");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to load tasks: $e");
    }
  }

  // Add a task to Todoist (v2 API)
  Future<void> postData(String taskName, String description, String priority) async {
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
          'priority': int.parse(priority), // Convert priority to int for Todoist
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchTasks();
        addController.clear();
        descriptionController.clear();
      } else {
        _showAlertDialog("Error", "Failed to add task");
      }
    } catch (e) {
      _showAlertDialog("Error", "Failed to add task: $e");
    }
  }

  // Update a task in Todoist (v2 API)
  Future<void> updateData(String id, String taskName, String description, String priority) async {
  try {
    // Step 1: Update the task locally before making the API call
    setState(() {
      final taskIndex = tasks.indexWhere((task) => task['id'] == id);
      if (taskIndex != -1) {
        tasks[taskIndex] = {
          'id': id,
          'content': taskName,
          'description': description,
          'priority': int.parse(priority),
        };
      }
    });

    // Step 2: Make the API call to update the task
    final response = await http.post(
      Uri.parse('https://api.todoist.com/rest/v2/tasks/$id'),
      headers: {
        'Authorization': 'Bearer $todoistApiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content': taskName,
        'description': description,
        'priority': int.parse(priority),
      }),
    );

    // Step 3: Check the API response status
    if (response.statusCode == 204) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
    } else {
      // Handle unexpected status code
      _showAlertDialog("Error", "Failed to update task: ${response.body}");
    }
  } catch (e) {
    // Handle any errors
    _showAlertDialog("Error", "Failed to update task: $e");
  }
}


 // Delete a task in Todoist (v2 API)
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

  // Map priority numbers to text
  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  // Sort tasks based on priority
  void _sortTasks() {
    tasks.sort((a, b) {
      int priorityComparison =
          (a['priority'] as int).compareTo(b['priority'] as int);
      return sortAscending ? priorityComparison : -priorityComparison;
    });
  }

  // Filter tasks by priority
  List<Map<String, dynamic>> _filterTasks() {
    if (filterPriority == 'All') {
      return tasks;
    }
    return tasks.where((task) {
      return _getPriorityText(task['priority']) == filterPriority;
    }).toList();
  }

  // Alert dialog to show errors
  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to open the update dialog
  void _openUpdateDialog(String id, String taskName, String description, String priority) {
    addController.text = taskName;
    descriptionController.text = description;
    selectedPriority = priority;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addController,
                decoration: const InputDecoration(labelText: "Task Name"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Task Description"),
              ),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('High')),
                  DropdownMenuItem(value: '2', child: Text('Medium')),
                  DropdownMenuItem(value: '3', child: Text('Low')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPriority = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (addController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  updateData(id, addController.text, descriptionController.text, selectedPriority);
                  Navigator.of(context).pop();
                } else {
                  _showAlertDialog("Error", "Please fill all fields");
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
        title: const Text("Todoist Todo App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTasks,
          ),
          // Updated icon to show vertical arrows
          IconButton(
            icon: sortAscending
                ? const Icon(Icons.arrow_upward)
                : const Icon(Icons.arrow_downward),
            onPressed: () {
              setState(() {
                sortAscending = !sortAscending;
                _sortTasks();
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filterPriority = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Priorities')),
              const PopupMenuItem(value: 'High', child: Text('High')),
              const PopupMenuItem(value: 'Medium', child: Text('Medium')),
              const PopupMenuItem(value: 'Low', child: Text('Low')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: addController,
              decoration: const InputDecoration(labelText: "Task Name"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Task Description"),
            ),
            DropdownButtonFormField<String>(
              value: selectedPriority,
              items: const [
                DropdownMenuItem(value: '1', child: Text('High')),
                DropdownMenuItem(value: '2', child: Text('Medium')),
                DropdownMenuItem(value: '3', child: Text('Low')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            ElevatedButton(
              onPressed: () {
                if (addController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  postData(addController.text, descriptionController.text, selectedPriority);
                } else {
                  _showAlertDialog("Error", "Please fill all fields");
                }
              },
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _filterTasks().length,
                itemBuilder: (context, index) {
                  final task = _filterTasks()[index];
                  return Card(
                    child: ListTile(
                      title: Text(task['content']),
                      subtitle: Text(
                          'Priority: ${_getPriorityText(task['priority'])}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _openUpdateDialog(task['id'], task['content'],
                                  task['description'], task['priority'].toString());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteData(task['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
