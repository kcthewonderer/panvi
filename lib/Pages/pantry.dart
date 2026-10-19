import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'Provider/shopping_list.dart';
import 'PantryPages/camera_page.dart';

// Constants
const _storageLocations = ['Fridge', 'Pantry', 'Freezer', 'Cabinet'];
const _itemCategories = ['Dairy', 'Protein', 'Veggie', 'Carbohydrate', 'Condiment'];
const _greetings = {
  'morning': 'Good Morning',
  'afternoon': 'Good Afternoon',
  'evening': 'Good Evening',
};

class PantryPage extends StatefulWidget {
  final String userName;
  const PantryPage({super.key, required this.userName});

  @override
  _PantryPageState createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  Map<String, List<Map<String, dynamic>>> _inventory = {
    for (var location in _storageLocations) location: [],
  };

  Map<String, int> _overview = {
    'Total Items': 0,
    'Expired Items': 0,
    'Items to Restock': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeInventoryData();
  }

  // Initialization Methods
  void _initializeInventoryData() {
    // Mock data - in a real app, this would come from a database
    setState(() {
      _inventory = {
        'Fridge': [
          _createItem(
            category: 'Dairy',
            name: 'Fresh milk carton',
            displayName: 'Milk',
            initialQuantity: 1,
            remainingQuantity: 1,
            quantityType: 'carton',
            nutritionalInfo: 'Calories: 150, Protein: 8g',
            storage: 'Refrigerate',
            expiration: '2024-10-10',
          ),
          _createItem(
            category: 'Protein',
            name: 'Eggs in carton',
            displayName: 'Eggs',
            initialQuantity: 12,
            remainingQuantity: 10,
            quantityType: 'eggs',
            nutritionalInfo: 'Calories: 70, Protein: 6g',
            storage: 'Refrigerate',
            expiration: '2024-10-15',
          ),
          _createItem(
            category: 'Veggie',
            name: 'Fresh green lettuce',
            displayName: 'Lettuce',
            initialQuantity: 1,
            remainingQuantity: 1,
            quantityType: 'head',
            nutritionalInfo: 'Calories: 15, Protein: 1g',
            storage: 'Refrigerate in crisper',
            expiration: '2024-10-05',
          ),
        ],
        'Pantry': [
          _createItem(
            category: 'Carbohydrate',
            name: 'Whole grain bread',
            displayName: 'Whole Grain Bread',
            initialQuantity: 20,
            remainingQuantity: 7,
            quantityType: 'slices',
            nutritionalInfo: 'Calories: 70, Protein: 2g',
            storage: 'Cool and dry place',
            expiration: '2024-09-30',
          ),
          _createItem(
            category: 'Condiment',
            name: 'Olive oil bottle',
            displayName: 'Olive Oil',
            initialQuantity: 1,
            remainingQuantity: 0.8,
            quantityType: 'bottle',
            nutritionalInfo: 'Calories: 120, Protein: 0g',
            storage: 'Dark cool place',
            expiration: '2025-06-01',
          ),
        ],
        'Freezer': [
          _createItem(
            category: 'Protein',
            name: 'Chicken breast',
            displayName: 'Chicken',
            initialQuantity: 1,
            remainingQuantity: 1,
            quantityType: 'package',
            nutritionalInfo: 'Calories: 165, Protein: 31g',
            storage: 'Freeze',
            expiration: '2024-12-15',
          ),
        ],
        'Cabinet': [
          _createItem(
            category: 'Condiment',
            name: 'Olive oil bottle',
            displayName: 'Olive Oil',
            initialQuantity: 1,
            remainingQuantity: 0.8,
            quantityType: 'bottle',
            nutritionalInfo: 'Calories: 120, Protein: 0g',
            storage: 'Dark cool place',
            expiration: '2025-06-01',
          ),
        ],
      };
      _calculateOverview();
    });
  }

  Map<String, dynamic> _createItem({
    required String category,
    required String name,
    required String displayName,
    required double initialQuantity,
    required double remainingQuantity,
    required String quantityType,
    required String nutritionalInfo,
    required String storage,
    required String expiration,
  }) {
    final status = _generateItemStatus(
      remainingQuantity: remainingQuantity,
      quantityType: quantityType,
      expiration: expiration,
    );

    return {
      'category': category,
      'name': name,
      'displayName': displayName,
      'status': status,
      'initialQuantity': initialQuantity,
      'remainingQuantity': remainingQuantity,
      'quantityType': quantityType,
      'nutritionalInfo': nutritionalInfo,
      'storage': storage,
      'expiration': expiration,
    };
  }

  String _generateItemStatus({
    required double remainingQuantity,
    required String quantityType,
    required String expiration,
  }) {
    final expirationDate = DateTime.tryParse(expiration) ?? DateTime.now();
    if (expirationDate.isBefore(DateTime.now())) {
      return 'Expired';
    }

    if (remainingQuantity <= 0) {
      return 'Out of stock';
    }

    if (['slices', 'eggs'].contains(quantityType)) {
      return '${remainingQuantity.toInt()} $quantityType left';
    }

    return '${remainingQuantity.toStringAsFixed(1)} $quantityType left';
  }

  void _calculateOverview() {
    int expiredItems = 0;
    int itemsToRestock = 0;
    int totalItems = 0;

    _inventory.forEach((location, items) {
      totalItems += items.length;
      expiredItems += items.where((item) {
        final expiration = DateTime.tryParse(item['expiration']) ?? DateTime.now();
        return expiration.isBefore(DateTime.now());
      }).length;

      itemsToRestock += items.where((item) {
        final initial = item['initialQuantity'] ?? 1;
        final remaining = item['remainingQuantity'] ?? 0;
        return remaining / initial < 0.25;
      }).length;
    });

    setState(() {
      _overview = {
        'Total Items': totalItems,
        'Expired Items': expiredItems,
        'Items to Restock': itemsToRestock,
      };
    });
  }

  // Navigation Methods
  void _navigateToStorageDetail(String storageType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Items in $storageType')),
          body: _buildStorageDetailView(storageType),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addItemManually(storageType),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showItemDetails(String storageType, int index) {
    final item = _inventory[storageType]?[index];
    if (item == null) return;

    final expirationDate = DateTime.tryParse(item['expiration']) ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['displayName']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${item['category']}'),
              const SizedBox(height: 8),
              Text('Storage: ${item['storage']}'),
              const SizedBox(height: 8),
              Text('Nutrition: ${item['nutritionalInfo']}'),
              const SizedBox(height: 8),
              Text('Expiration: ${item['expiration']}'),
              const SizedBox(height: 16),
              _buildQuantityProgressBar(item),
              const SizedBox(height: 8),
              _buildFreshnessProgressBar(expirationDate),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // UI Components
  Widget _buildStorageCard(String storageType) {
    final items = _inventory[storageType] ?? [];
    final displayedItems = items.take(3).toList();
    final hasMoreItems = items.length > 3;

    return GestureDetector(
      onTap: () => _navigateToStorageDetail(storageType),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getStorageIcon(storageType),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Items in $storageType',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (hasMoreItems)
                    Text(
                      '+${items.length - 3} more',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (displayedItems.isEmpty)
                const Text(
                  'No items yet',
                  style: TextStyle(color: Colors.grey),
                )
              else
                Column(
                  children: displayedItems
                      .map((item) => _buildStorageItemRow(item))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageDetailView(String storageType) {
    final items = _inventory[storageType] ?? [];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => _buildSlidableItemCell(
        items[index],
        storageType,
        index,
        showFullDetails: true,
      ),
    );
  }

  Widget _buildStorageItemRow(Map<String, dynamic> item) {
    final expirationDate = DateTime.tryParse(item['expiration']) ?? DateTime.now();
    final isExpired = expirationDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['displayName'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isExpired ? Colors.red : null,
              ),
            ),
          ),
          Text(
            item['status'],
            style: TextStyle(
              color: _getStatusColor(item),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidableItemCell(
      Map<String, dynamic> item,
      String storageType,
      int index, {
        bool showFullDetails = false,
      }) {
    return Slidable(
      key: Key('${item['name']}-$index-$storageType'),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _addToShoppingList(context, item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.add_shopping_cart,
            label: 'Add to List',
          ),
          SlidableAction(
            onPressed: (context) => _deleteItem(storageType, index),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showItemDetails(storageType, index),
        onLongPress: () => _editAmountLeft(storageType, index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: showFullDetails
              ? _buildFullItemDetails(item)
              : _buildCompactItemDetails(item),
        ),
      ),
    );
  }

  Widget _buildFullItemDetails(Map<String, dynamic> item) {
    final expirationDate = DateTime.tryParse(item['expiration']) ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Display Name: ${item['displayName']}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          'Status: ${item['status']}',
          style: TextStyle(color: _getStatusColor(item)),
        ),
        const SizedBox(height: 8),
        Text(
          'Expiration: ${item['expiration']}',
          style: TextStyle(
            color: expirationDate.isBefore(DateTime.now())
                ? Colors.red
                : Colors.grey[600],
          ),
        ),
        Text(
          'Storage: ${item['storage']}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          'Nutrition: ${item['nutritionalInfo']}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCompactItemDetails(Map<String, dynamic> item) {
    final expirationDate = DateTime.tryParse(item['expiration']) ?? DateTime.now();
    final isExpired = expirationDate.isBefore(DateTime.now());
    final isLow = (item['remainingQuantity'] / item['initialQuantity']) < 0.25;

    return Row(
      children: [
        if (isExpired)
          const Icon(Icons.warning, size: 16, color: Colors.red),
        if (isLow && !isExpired)
          const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['displayName'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpired ? Colors.red : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item['status'],
                style: TextStyle(
                  color: _getStatusColor(item),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityProgressBar(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _getAmountLeftPercentage(item),
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text('${item['remainingQuantity']} ${item['quantityType']} left'),
      ],
    );
  }

  Widget _buildFreshnessProgressBar(DateTime expirationDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: _getFreshnessPercentage(expirationDate),
          backgroundColor: Colors.grey[300],
          color: _getFreshnessColor(expirationDate),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text('Freshness: ${_getFreshnessText(expirationDate)}'),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Overview',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _overview.entries
                  .map((entry) => _buildOverviewCard(entry.key, entry.value))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, int value) {
    final iconData = _getOverviewIcon(title);
    final color = _getOverviewColor(title);

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(iconData, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedOverviewCard(String title, int value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 32, color: _getOverviewColor(title)),
        title: Text(title),
        subtitle: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getOverviewColor(title),
          ),
        ),
      ),
    );
  }

  // Item Management Methods
  void _addToShoppingList(BuildContext context, Map<String, dynamic> item) {
    Provider.of<ShoppingListProvider>(context, listen: false)
        .addItem(item['displayName']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['displayName']} added to shopping list'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteItem(String storageType, int index) {
    setState(() {
      _inventory[storageType]?.removeAt(index);
      _calculateOverview();
    });
  }

  void _editAmountLeft(String storageType, int index) {
    final item = _inventory[storageType]?[index];
    if (item == null) return;

    showDialog(
      context: context,
      builder: (context) {
        String newAmount = item['remainingQuantity'].toString();

        return AlertDialog(
          title: Text('Edit ${item['displayName']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount Left (${item['quantityType']})',
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: newAmount),
                onChanged: (value) => newAmount = value,
              ),
              const SizedBox(height: 16),
              Text(
                'Expiration: ${item['expiration']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final newValue = double.tryParse(newAmount) ?? item['remainingQuantity'];
                  _inventory[storageType]![index]['remainingQuantity'] = newValue;
                  _inventory[storageType]![index]['status'] = _generateItemStatus(
                    remainingQuantity: newValue,
                    quantityType: item['quantityType'],
                    expiration: item['expiration'],
                  );

                  if (newValue <= 0) {
                    _deleteItem(storageType, index);
                  }

                  _calculateOverview();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanNewItem() async {
    final scannedItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage(cameras: cameras)),
    );

    if (scannedItem != null && scannedItem is Map<String, dynamic>) {
      setState(() {
        final storageType = ['Dairy', 'Protein', 'Veggie'].contains(scannedItem['category'])
            ? 'Fridge'
            : 'Pantry';
        _inventory[storageType]?.add(scannedItem);
        _calculateOverview();
      });
    }
  }

  void _addItemManually(String storageType) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (newItem) {
          setState(() {
            _inventory[storageType]?.add(newItem);
            _calculateOverview();
          });
        },
      ),
    );
  }

  // Helper Methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return _greetings['morning']!;
    if (hour < 17) return _greetings['afternoon']!;
    return _greetings['evening']!;
  }

  IconData _getStorageIcon(String storageType) {
    switch (storageType) {
      case 'Fridge':
        return Icons.kitchen;
      case 'Freezer':
        return Icons.ac_unit;
      case 'Pantry':
        return Icons.shelves;
      case 'Cabinet':
        return Icons.weekend;
      default:
        return Icons.storage;
    }
  }

  IconData _getOverviewIcon(String title) {
    switch (title) {
      case 'Expired Items':
        return Icons.warning_amber_rounded;
      case 'Items to Restock':
        return Icons.shopping_cart;
      default:
        return Icons.list_alt;
    }
  }

  Color _getOverviewColor(String title) {
    switch (title) {
      case 'Expired Items':
        return Colors.red;
      case 'Items to Restock':
        return Colors.orange;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Color _getStatusColor(Map<String, dynamic> item) {
    if (item['status'].toString().toLowerCase().contains('expired') ||
        item['status'].toString().toLowerCase().contains('out of stock')) {
      return Colors.red;
    }
    if ((item['remainingQuantity'] / item['initialQuantity']) < 0.25) {
      return Colors.orange;
    }
    return Colors.black;
  }

  Color _getFreshnessColor(DateTime expiration) {
    final now = DateTime.now();
    if (expiration.isBefore(now)) return Colors.red;
    if (expiration.isBefore(now.add(const Duration(days: 3)))) return Colors.orange;
    if (expiration.isBefore(now.add(const Duration(days: 7)))) return Colors.yellow;
    return Colors.green;
  }

  String _getFreshnessText(DateTime expiration) {
    final now = DateTime.now();
    if (expiration.isBefore(now)) return 'Expired';

    final difference = expiration.difference(now);
    if (difference.inDays > 0) return '${difference.inDays} days remaining';
    if (difference.inHours > 0) return '${difference.inHours} hours remaining';
    return 'Expires soon';
  }
  String _getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  double _getAmountLeftPercentage(Map<String, dynamic> item) {
    final initial = item['initialQuantity'] ?? 1.0;
    if (initial == 0) return 0.0;
    return (item['remainingQuantity'] ?? 0.0) / initial;
  }

  double _getFreshnessPercentage(DateTime expiration) {
    final now = DateTime.now();
    if (expiration.isBefore(now)) return 0.0;
    if (expiration.isBefore(now.add(const Duration(days: 3)))) return 0.33;
    if (expiration.isBefore(now.add(const Duration(days: 7)))) return 0.66;
    return 1.0;
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, ${_getFirstName(widget.userName)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Text(
              'Your Food Inventory',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: _addNewStorageLocation,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Freezer',
                child: Text('Add Freezer'),
              ),
              const PopupMenuItem(
                value: 'Cabinet',
                child: Text('Add Cabinet'),
              ),
              const PopupMenuItem(
                value: 'Custom',
                child: Text('Add Custom Location'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final location in _storageLocations)
                  if (_inventory[location]?.isNotEmpty ?? false) ...[
                    _buildStorageCard(location),
                    const SizedBox(height: 16),
                  ],
                GestureDetector(
                  onTap: () => _showFullOverview(context),
                  child: _buildOverviewCards(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanNewItem,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Scan Item'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  // Search Functionality
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return AlertDialog(
          title: const Text('Search Inventory'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by item name...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => searchQuery = value.toLowerCase(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSearchResults(context, searchQuery);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(BuildContext context, String query) {
    final results = _inventory.values
        .expand((items) => items)
        .where((item) =>
    item['name'].toString().toLowerCase().contains(query) ||
        item['displayName'].toString().toLowerCase().contains(query))
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return ListTile(
            title: Text(item['displayName']),
            subtitle: Text(item['status']),
            onTap: () {
              Navigator.pop(context);
              final storageType = _findStorageTypeForItem(item);
              if (storageType != null) {
                final itemIndex = _inventory[storageType]!.indexOf(item);
                _showItemDetails(storageType, itemIndex);
              }
            },
          );
        },
      ),
    );
  }

  String? _findStorageTypeForItem(Map<String, dynamic> item) {
    for (final entry in _inventory.entries) {
      if (entry.value.contains(item)) {
        return entry.key;
      }
    }
    return null;
  }

  // Storage Location Management
  void _addNewStorageLocation(String locationType) {
    if (locationType == 'Custom') {
      _showAddCustomStorageDialog();
    } else {
      setState(() {
        _inventory[locationType] = [];
      });
    }
  }

  void _showAddCustomStorageDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Storage'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Storage Location Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _inventory[controller.text] = [];
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Overview Display
  void _showFullOverview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        initialChildSize: 0.7,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Full Inventory Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailedOverviewCard('Total Items', _overview['Total Items']!, Icons.list_alt),
                _buildDetailedOverviewCard('Expired Items', _overview['Expired Items']!, Icons.warning),
                _buildDetailedOverviewCard('Items to Restock', _overview['Items to Restock']!, Icons.shopping_cart),
                const SizedBox(height: 16),
                const Text(
                  'Storage Locations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _inventory.entries
                      .where((entry) => entry.value.isNotEmpty)
                      .map((entry) => Chip(
                    label: Text('${entry.key} (${entry.value.length})'),
                    avatar: Icon(_getStorageIcon(entry.key)),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Add Item Dialog Widget
class _AddItemDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  __AddItemDialogState createState() => __AddItemDialogState();
}

class __AddItemDialogState extends State<_AddItemDialog> {
  String _category = 'Dairy';
  String _name = '';
  String _displayName = '';
  double _initialQuantity = 1;
  String _quantityType = 'unit';
  String _nutritionalInfo = '';
  String _storage = '';
  String _expiration = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _category,
              items: _itemCategories
                  .map((value) => DropdownMenuItem(
                value: value,
                child: Text(value),
              ))
                  .toList(),
              onChanged: (newValue) => setState(() => _category = newValue!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Name (e.g., Fresh milk carton)'),
              onChanged: (value) => _name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Display Name (e.g., Milk)'),
              onChanged: (value) => _displayName = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Initial Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _initialQuantity = double.tryParse(value) ?? 1,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Quantity Type (e.g., carton, slices)'),
              onChanged: (value) => _quantityType = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Nutritional Info'),
              onChanged: (value) => _nutritionalInfo = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Storage Instructions'),
              onChanged: (value) => _storage = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Expiration Date (YYYY-MM-DD)'),
              onChanged: (value) => _expiration = value,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            final newItem = {
              'category': _category,
              'name': _name.isNotEmpty ? _name : 'New Item',
              'displayName': _displayName.isNotEmpty ? _displayName : 'New Item',
              'status': '${_initialQuantity} $_quantityType left',
              'initialQuantity': _initialQuantity,
              'remainingQuantity': _initialQuantity,
              'quantityType': _quantityType,
              'nutritionalInfo': _nutritionalInfo,
              'storage': _storage,
              'expiration': _expiration,
            };
            widget.onAdd(newItem);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}