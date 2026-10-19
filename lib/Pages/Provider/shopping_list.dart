import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShoppingListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> shoppingLists = [
    {'name': 'Default', 'items': []},
  ];

  List<Map<String, dynamic>> pantryItems = [
    {
      'name': 'Milk',
      'initialQuantity': 1,
      'quantityType': 'gallon',
      'remainingQuantity': 1,
      'nutritionalInfo': 'Calories: 150, Protein: 8g',
      'storage': 'Refrigerate',
      'expiration': '2024-06-01'
    },
    {
      'name': 'Bread',
      'initialQuantity': 1,
      'quantityType': 'loaf',
      'remainingQuantity': 1,
      'nutritionalInfo': 'Calories: 70, Protein: 2g',
      'storage': 'Cool and dry place',
      'expiration': '2024-05-25'
    },
    // Add more items as needed
  ];

  String selectedListName = 'Default';

  void addItem(String itemName) {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    selectedList['items'].add({'name': itemName, 'checked': false, 'selected': false});
    notifyListeners();
  }

  void editItem(int index, String newItemName) {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    selectedList['items'][index]['name'] = newItemName;
    notifyListeners();
  }

  void deleteSelectedItems() {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    selectedList['items'].removeWhere((item) => item['selected']);
    notifyListeners();
  }

  void toggleItemChecked(int index) {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    selectedList['items'][index]['checked'] = !selectedList['items'][index]['checked'];
    notifyListeners();
  }

  void toggleItemSelected(int index) {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    selectedList['items'][index]['selected'] = !selectedList['items'][index]['selected'];
    notifyListeners();
  }

  void selectAllItems() {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    bool allSelected = selectedList['items'].every((item) => item['selected']);
    for (var item in selectedList['items']) {
      item['selected'] = !allSelected;
    }
    notifyListeners();
  }

  void createNewList(String listName) {
    shoppingLists.add({'name': listName, 'items': []});
    notifyListeners();
  }

  void deleteShoppingList(String listName) {
    shoppingLists.removeWhere((list) => list['name'] == listName);
    if (selectedListName == listName && shoppingLists.isNotEmpty) {
      selectedListName = shoppingLists.first['name'];
    } else if (shoppingLists.isEmpty) {
      selectedListName = '';
    }
    notifyListeners();
  }

  void selectList(String listName) {
    selectedListName = listName;
    notifyListeners();
  }

  void clearList() {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    selectedList['items'].clear();
    notifyListeners();
  }

  void shareShoppingList() {
    var selectedList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    String listContent = selectedList['items'].map((item) => item['name']).join(', ');
    Share.share('Shopping List: $listContent');
  }

  void moveSelectedItemsToList(String targetListName) {
    var currentList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    var targetList = shoppingLists.firstWhere((list) => list['name'] == targetListName);

    List<Map<String, dynamic>> itemsToMove = [];
    for (var item in currentList['items']) {
      if (item['selected']) {
        itemsToMove.add(item);
      }
    }

    for (var item in itemsToMove) {
      currentList['items'].remove(item);
      targetList['items'].add(item);
    }

    notifyListeners();
  }

  void copySelectedItemsToList(String targetListName) {
    var currentList = shoppingLists.firstWhere((list) => list['name'] == selectedListName);
    var targetList = shoppingLists.firstWhere((list) => list['name'] == targetListName);

    List<Map<String, dynamic>> itemsToCopy = [];
    for (var item in currentList['items']) {
      if (item['selected']) {
        itemsToCopy.add(item);
      }
    }

    for (var item in itemsToCopy) {
      targetList['items'].add({...item, 'selected': false}); // Create a copy of the item
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> getPantryItems() {
    return pantryItems;
  }
}