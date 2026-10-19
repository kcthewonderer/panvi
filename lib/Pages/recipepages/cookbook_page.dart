import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CookbookPage extends StatefulWidget {
  const CookbookPage({super.key});

  @override
  CookbookPageState createState() => CookbookPageState();
}

class CookbookPageState extends State<CookbookPage> {
  final List<Map<String, dynamic>> _cookbooks = [
    {'name': 'Family Recipes', 'author': 'John Doe', 'public': true},
    {'name': 'Healthy Meals', 'author': 'Jane Smith', 'public': false},
  ];

  void _createNewCookbook() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String cookbookName = '';
        String authorName = '';
        bool isPublic = false;

        return AlertDialog(
          title: const Text('Create New Cookbook'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Cookbook Name'),
                onChanged: (value) {
                  cookbookName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Author Name'),
                onChanged: (value) {
                  authorName = value;
                },
              ),
              Row(
                children: <Widget>[
                  const Text('Public'),
                  Checkbox(
                    value: isPublic,
                    onChanged: (bool? value) {
                      setState(() {
                        isPublic = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                setState(() {
                  _cookbooks.add({'name': cookbookName, 'author': authorName, 'public': isPublic});
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _searchCookbooks(String query) {
    // Implement search logic here
  }

  void _showCookbookOptions(Map<String, dynamic> cookbook) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isPublic = cookbook['public'];

        return AlertDialog(
          title: Text(cookbook['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Author: ${cookbook['author']}'),
              Row(
                children: <Widget>[
                  const Text('Public'),
                  Checkbox(
                    value: isPublic,
                    onChanged: (bool? value) {
                      setState(() {
                        isPublic = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _cookbooks.remove(cookbook);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: const Text('Cookbooks'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Cookbooks',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchCookbooks(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _cookbooks.length,
              itemBuilder: (context, index) {
                var cookbook = _cookbooks[index];
                return Slidable(
                  key: ValueKey(cookbook['name']),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // Archive logic
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.archive,
                        label: 'Archive',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showCookbookOptions(cookbook),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(cookbook['name']),
                    subtitle: Text('Author: ${cookbook['author']}'),
                    onTap: () => _showCookbookOptions(cookbook),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCookbook,
        tooltip: 'Create Cookbook',
        child: const Icon(Icons.add),
      ),
    );
  }
}