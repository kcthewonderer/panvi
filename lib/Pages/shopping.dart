import 'package:flutter/material.dart';
import 'Provider/shopping_list.dart';
import 'package:provider/provider.dart';
import 'PantrySelect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  bool _isSelecting = false;
  final List<int> _selectedIndices = [];

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/test'));

    if (response.statusCode == 200) {
      print('Response: ${json.decode(response.body)}');
    } else {
      print('Failed to load data');
    }
  }

  Future<void> sendData() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'key': 'value'}),
    );

    if (response.statusCode == 200) {
      print('Response: ${json.decode(response.body)}');
    } else {
      print('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, shoppingListProvider, child) {
        var selectedList = shoppingListProvider.shoppingLists.firstWhere(
              (list) => list['name'] == shoppingListProvider.selectedListName,
          orElse: () => {'name': '', 'items': []},
        );

        _isSelecting = selectedList['items'].any((item) => item['selected'] == true);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lists'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: shoppingListProvider.shareShoppingList,
                tooltip: 'Share Shopping List',
              ),
              if (_isSelecting)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    shoppingListProvider.deleteSelectedItems();
                  },
                  tooltip: 'Delete Selected Items',
                ),
              if (_isSelecting)
                IconButton(
                  icon: const Icon(Icons.move_to_inbox),
                  onPressed: () {
                    _showMoveCopyDialog(context, shoppingListProvider, move: true);
                  },
                  tooltip: 'Move Selected Items',
                ),
              if (_isSelecting)
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    _showMoveCopyDialog(context, shoppingListProvider, move: false);
                  },
                  tooltip: 'Copy Selected Items',
                ),
              IconButton(
                icon: Icon(_isSelecting ? Icons.close : Icons.select_all),
                onPressed: () {
                  setState(() {
                    if (_isSelecting) {
                      _isSelecting = false;
                      _selectedIndices.clear();
                    } else {
                      _isSelecting = true;
                      _selectedIndices.addAll(
                        List<int>.generate(selectedList['items'].length, (index) => index),
                      );
                    }
                  });
                },
                tooltip: _isSelecting ? 'Cancel Selection' : 'Select All',
              ),
            ],
          ),
          drawer: _buildDrawer(context, shoppingListProvider),
          body: selectedList['items'].isEmpty
              ? const Center(child: Text('No items in the list'))
              : ListView.builder(
            itemCount: selectedList['items'].length,
            itemBuilder: (context, index) {
              var item = selectedList['items'][index];
              bool isSelected = _selectedIndices.contains(index);

              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    _isSelecting = true;
                    _selectedIndices.add(index);
                  });
                },
                onTap: () {
                  if (_isSelecting) {
                    setState(() {
                      isSelected
                          ? _selectedIndices.remove(index)
                          : _selectedIndices.add(index);
                    });
                  }
                },
                child: Container(
                  color: isSelected ? Colors.grey[300] : Colors.transparent,
                  child: ListTile(
                    title: Text(item['name']),
                    leading: Checkbox(
                      value: item['checked'] == true,
                      onChanged: (bool? value) {
                        shoppingListProvider.toggleItemChecked(index);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: _buildFAB(context, shoppingListProvider),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, ShoppingListProvider shoppingListProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Shopping Lists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ...shoppingListProvider.shoppingLists.map<Widget>((list) {
            return ListTile(
              title: Text(list['name']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  shoppingListProvider.deleteShoppingList(list['name']);
                },
              ),
              onTap: () {
                shoppingListProvider.selectList(list['name']);
                Navigator.pop(context);
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create New List'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String newListName = '';

                  return AlertDialog(
                    title: const Text('Create New Shopping List'),
                    content: TextField(
                      decoration: const InputDecoration(labelText: 'List Name'),
                      onChanged: (value) {
                        newListName = value;
                      },
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
                          if (newListName.isNotEmpty) {
                            shoppingListProvider.createNewList(newListName);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('List name cannot be empty.')),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context, ShoppingListProvider shoppingListProvider) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Item Manually'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddItemDialog(context, shoppingListProvider);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.kitchen),
                  title: const Text('Add Item from Pantry'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantrySelectionPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Add Items from Recipe'),
                  onTap: () {
                    Navigator.of(context).pop();
                    shoppingListProvider.addItem('Item from Recipe');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Items from recipe added.')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      tooltip: 'Add Item',
      child: const Icon(Icons.add),
    );
  }

  void _showAddItemDialog(BuildContext context, ShoppingListProvider shoppingListProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItemName = '';
        TextEditingController controller = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Item'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (value) {
                  newItemName = value;
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Finish'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (newItemName.isNotEmpty) {
                      shoppingListProvider.addItem(newItemName);
                      setState(() {
                        newItemName = ''; // Clear the input field for the next item
                        controller.clear(); // Clear the text field
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item name cannot be empty.')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMoveCopyDialog(BuildContext context, ShoppingListProvider shoppingListProvider, {required bool move}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      String selectedListName = shoppingListProvider.selectedListName;
      return StatefulBuilder(
          builder: (context, setState) {
        return AlertDialog(
            title: Text(move ? 'Move Items To' : 'Copy Items To'),
    content: DropdownButton<String>(
    isExpanded: true,
    value: selectedListName,
    onChanged: (String? newValue) {
    if (newValue != null) {
    setState(() {
    selectedListName = newValue;
    });
    }
    },
    items: shoppingListProvider.shoppingLists
        .map<DropdownMenuItem<String>>((Map<String, dynamic> list) {
    return DropdownMenuItem<String>(
    value: list['name']as String,
      child: Text(list['name'] as String),
    );
    }).toList(),
    ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(move ? 'Move' : 'Copy'),
              onPressed: () {
                if (move) {
                  shoppingListProvider.moveSelectedItemsToList(selectedListName);
                } else {
                  shoppingListProvider.copySelectedItemsToList(selectedListName);
                }
                setState(() {
                  _isSelecting = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
          },
      );
        },
    );
  }
}