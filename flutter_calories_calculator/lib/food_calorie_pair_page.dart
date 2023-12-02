import 'package:flutter/material.dart';

import 'database_helper.dart';

class FoodCaloriePairPage extends StatefulWidget {
  const FoodCaloriePairPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FoodCaloriePairPageState createState() => _FoodCaloriePairPageState();
}

class _FoodCaloriePairPageState extends State<FoodCaloriePairPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Map<String, dynamic>> foodCaloriePairs = []; // Initialize to an empty list

  @override
  void initState() {
    super.initState();
    _loadFoodCaloriePairs();
  }

  Future<void> _loadFoodCaloriePairs() async {
    List<Map<String, dynamic>> fetchedData = await databaseHelper.getFoodCalories();
    setState(() {
      foodCaloriePairs = fetchedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Calories'),
      ),
      body: ListView.builder(
        itemCount: foodCaloriePairs.length,
        itemBuilder: (context, index) {
          final foodItem = foodCaloriePairs[index];
          return ListTile(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddFoodPage(); // Navigate to the add food page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Implement this method to delete a food pair from the database
  void _deleteFoodPair(int id) async {
    // Implement delete functionality using databaseHelper
    // After deletion, reload the food calorie pairs
    await databaseHelper.deleteFoodPair(id);
    await _loadFoodCaloriePairs();
  }

  // Implement this method to navigate to the update food page
  void _navigateToUpdateFoodPage(Map<String, dynamic> foodItem) {
    // Implement navigation to update food page using foodItem data
    // This can navigate to a new screen to edit the item
    // For simplicity, it's left empty in this example
  }

  // Implement this method to navigate to the add food page
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

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddFoodPageState createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

  void _saveFoodItem() async {
    String? foodName = _foodNameController.text;
    int? calories = int.tryParse(_caloriesController.text);

    if (foodName != null && calories != null) {
      DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.addFoodCaloriePair(foodName, calories);

      // Navigate back after saving
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }


  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
