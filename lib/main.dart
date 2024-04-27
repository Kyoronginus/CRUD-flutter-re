import 'package:flutter/material.dart';
import 'onboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _isVisited = 0;

void updateIsVisited(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('_isVisited', value);
}

Future<int> getIsVisited() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('_isVisited') ?? 0;
}

void taskEmptyErr(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Uh Oh"),
        content: Text("Task name cannot be empty."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _isVisited = await getIsVisited();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isVisited == 0 ? OnboardingScreen() : TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, String>> tasks = [];

  void addTask(String task, String description) {
    setState(() {
      tasks.add({
        'task': task,
        'description': description,
      });
    });
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void updateTask(int index, String task, String description) {
    setState(() {
      tasks[index]["task"] = task;
      tasks[index]["description"] = description;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
        backgroundColor: Colors.yellow,
      ),
      body: ListView.builder(
        itemCount: tasks.isEmpty ? 1 : tasks.length,
        itemBuilder: (context, index) {
          if (tasks.isEmpty) {
            return const Center(
              child: Align(
                child: Text(
                  "Nothing to see here",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return ListTile(
              title: Text(tasks[index]["task"]!),
              subtitle: Text(tasks[index]["description"] ?? ""),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => removeTask(index),
              ),
              onTap: () {
                String? editedTask = tasks[index]["task"];
                String? editedDescription =
                    tasks[index]["description"] ?? '';
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Edit Task'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            onChanged: (value) {
                              editedTask = value;
                            },
                            controller:
                                TextEditingController(text: tasks[index]['task']),
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'Task Name'),
                          ),
                          TextField(
                            onChanged: (value) {
                              editedDescription = value;
                            },
                            controller: TextEditingController(
                                text: tasks[index]['description']),
                            decoration: InputDecoration(labelText: 'Description'),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (editedTask == null || editedTask!.isEmpty) {
                              taskEmptyErr(context);
                              return;
                            }
                            updateTask(index, editedTask!, editedDescription!);
                            Navigator.of(context).pop();
                          },
                          child: Text('Save'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String newTask = '';
          String description = "";
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Task'),
                content: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        newTask = value;
                      },
                      autofocus: true,
                      decoration: InputDecoration(labelText: "Task Name"),
                    ),
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                      decoration: InputDecoration(labelText: "Description"),
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (newTask.isEmpty) {
                        taskEmptyErr(context);
                        return;
                      }
                      addTask(newTask, description);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
