import 'package:flutter/material.dart';
import 'database_helper.dart';

// StatefulWidget to display food calorie pairs
class FoodCaloriePairPage extends StatefulWidget {
  const FoodCaloriePairPage({Key? key}) : super(key: key);

  @override
  _FoodCaloriePairPageState createState() => _FoodCaloriePairPageState();
}

// State class for displaying food calorie pairs
class _FoodCaloriePairPageState extends State<FoodCaloriePairPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Map<String, dynamic>> foodCaloriePairs = [];

  @override
  void initState() {
    super.initState();
    _loadFoodCaloriePairs();
  }

  // Loading food calorie pairs from the database
  Future<void> _loadFoodCaloriePairs() async {
    List<Map<String, dynamic>> fetchedData = await databaseHelper.getFoodCalories();
    setState(() {
      foodCaloriePairs = fetchedData;
    });
  }

  // Building the UI to display food calorie pairs
  @override
  Widget build(BuildContext context) {
    // Scaffold with an app bar, list view of food items, and a floating action button
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Calories'),
      ),
      body: ListView.builder(
        itemCount: foodCaloriePairs.length,
        itemBuilder: (context, index) {
          final foodItem = foodCaloriePairs[index];
          return ListTile(
            // Displaying food item and calories, adding delete functionality
            title: Text(foodItem['food']),
            subtitle: Text('${foodItem['calories']} calories'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteFoodPair(foodItem['id']); // Implement delete functionality
              },
            ),
            onTap: () {
              _navigateToUpdateFoodPage(foodItem); // Implement update functionality
            },
          );
        },
      ),
      // Floating action button to navigate to the add food page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddFoodPage(); // Navigate to the add food page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Function to delete a food pair from the database
  void _deleteFoodPair(int id) async {
    await databaseHelper.deleteFoodPair(id);
    await _loadFoodCaloriePairs();
  }

  // Methods to navigate to update food page and add food page
  void _navigateToUpdateFoodPage(Map<String, dynamic> foodItem) {
    // Navigation to update food page (left empty for simplicity)
  }

  void _navigateToAddFoodPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddFoodPage(),
      ),
    ).then((_) {
      _loadFoodCaloriePairs(); // Reload food calorie pairs after adding a new one
    });
  }
}

// StatefulWidget to add a new food item
class AddFoodPage extends StatefulWidget {
  const AddFoodPage({Key? key}) : super(key: key);

  @override
  _AddFoodPageState createState() => _AddFoodPageState();
}

// State class to handle adding a new food item
class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Scaffold to add a new food item with form fields for food name and calories
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextFormFields for entering food name and calories
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the calories';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Button to save the new food item
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveFoodItem();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to save the new food item to the database
  void _saveFoodItem() async {
    String? foodName = _foodNameController.text;
    int? calories = int.tryParse(_caloriesController.text);

    if (foodName != null && calories != null) {
      DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.addFoodCaloriePair(foodName, calories);

      Navigator.pop(context); // Navigate back after saving
    }
  }

  // Dispose method to clean up controllers
  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
