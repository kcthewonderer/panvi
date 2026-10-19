import 'package:flutter/material.dart';
import 'Provider/shopping_list.dart';
import 'package:provider/provider.dart';

class PantrySelectionPage extends StatelessWidget {
  const PantrySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, shoppingListProvider, child) {
        var pantryItems = shoppingListProvider.getPantryItems();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Items from Pantry'),
          ),
          body: ListView.builder(
            itemCount: pantryItems.length,
            itemBuilder: (context, index) {
              var item = pantryItems[index];
              var expirationDate = DateTime.tryParse(item['expiration']) ?? DateTime.now();

              return ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    shoppingListProvider.addItem(item['name']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item['name']} added to shopping list')),
                    );
                  },
                ),
                title: Text(item['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount left: ${item['remainingQuantity']} ${item['quantityType']}'),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _getFreshnessPercentage(expirationDate),
                            backgroundColor: Colors.grey[300],
                            color: _getFreshnessColor(expirationDate),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Freshness'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getFreshnessColor(DateTime expiration) {
    DateTime now = DateTime.now();
    if (expiration.isBefore(now)) {
      return Colors.black;
    } else if (expiration.isBefore(now.add(const Duration(days: 3)))) {
      return Colors.red;
    } else if (expiration.isBefore(now.add(const Duration(days: 7)))) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  double _getFreshnessPercentage(DateTime expiration) {
    DateTime now = DateTime.now();
    int totalDays = expiration.difference(now).inDays;
    if (totalDays <= 0) return 0.0;
    if (totalDays <= 3) return 0.33;
    if (totalDays <= 7) return 0.66;
    return 1.0;
  }
}