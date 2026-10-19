import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'recipepages/cookbook_page.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final List<Map<String, dynamic>> _recipes = [
    {'name': 'Spaghetti', 'prepTime': '15 min', 'cookTime': '30 min', 'ingredients': ['Spaghetti', 'Tomato Sauce', 'Garlic'], 'instructions': 'Boil water, cook spaghetti, add sauce.', 'popular': true},
    {'name': 'Grilled Cheese', 'prepTime': '5 min', 'cookTime': '10 min', 'ingredients': ['Bread', 'Cheese', 'Butter'], 'instructions': 'Butter bread, add cheese, grill.', 'popular': true},
    {'name': 'Chicken Salad', 'prepTime': '10 min', 'cookTime': '20 min', 'ingredients': ['Chicken', 'Lettuce', 'Tomatoes'], 'instructions': 'Cook chicken, mix with salad.', 'popular': false},
  ];

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(recipe['name']),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Add to favorites logic
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prep Time:'),
                    Text('Cook Time:'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(recipe['prepTime']),
                    Text(recipe['cookTime']),
                  ],
                ),
                const Divider(height:4.0,thickness: 1.0),
                const SizedBox(height: 8.0),
                Text('Ingredients: ${recipe['ingredients'].join(', ')}'),
                const Divider(height:4.0,thickness: 1.0),
                const SizedBox(height: 8.0),
                Text('Instructions: ${recipe['instructions']}'),
              ],
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'Meal Plan':
                  // Add to meal plan logic
                    break;
                  case 'Shopping List':
                  // Add to shopping list logic
                    break;
                  case 'Cookbook':
                  // Add to cookbook logic
                    break;
                }
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.add),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Meal Plan',
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Add to Meal Plan'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Shopping List',
                  child: ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('Add to Shopping List'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Cookbook',
                  child: ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Add to Cookbook'),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 122), // Add space between the buttons
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
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigate to favorites page
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CookbookPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Recipes',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Handle search logic
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Popular Recipes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ..._recipes.where((recipe) => recipe['popular']).map((recipe) {
                  return ListTile(
                    title: Text(recipe['name']),
                    onTap: () => _showRecipeDetails(recipe),
                  );
                }),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Suggested Recipes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                CarouselSlider(
                  options: CarouselOptions(height: 200.0),
                  items: _recipes.map((recipe) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () => _showRecipeDetails(recipe),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: const BoxDecoration(color: Colors.amber),
                            child: Center(
                              child: Text(recipe['name'], style: const TextStyle(fontSize: 16.0)),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}