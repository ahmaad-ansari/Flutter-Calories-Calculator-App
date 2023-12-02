// Import necessary packages and files
import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

// Widget for updating an existing meal plan
class UpdateMealPlanPage extends StatefulWidget {
  final Map<String, dynamic> mealPlan; // Meal plan data to be updated

  const UpdateMealPlanPage({Key? key, required this.mealPlan}) : super(key: key);

  @override
  _UpdateMealPlanPageState createState() => _UpdateMealPlanPageState();
}

class _UpdateMealPlanPageState extends State<UpdateMealPlanPage> {
  late TextEditingController _targetCaloriesController; // Controller for target calories input
  late DateTime _selectedDate; // Variable to store the selected date
  List<Map<String, dynamic>> _selectedFoodItems = []; // List to store selected food items
  List<Map<String, dynamic>> _availableFoodItems = []; // List to store available food items
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Database helper instance

  @override
  void initState() {
    super.initState();
    // Initialize controllers and selected date from meal plan data
    _targetCaloriesController = TextEditingController(text: widget.mealPlan['targetCalories'].toString());
    _selectedDate = DateTime.parse(widget.mealPlan['date']);

    // Parse food items from JSON and update selected food items
    var foodItemsJson = jsonDecode(widget.mealPlan['foodItems']);
    if (foodItemsJson is List) {
      _selectedFoodItems = List<Map<String, dynamic>>.from(foodItemsJson.map((item) => Map<String, dynamic>.from(item)));
    }

    _loadAvailableFoodItems(); // Load available food items
  }

  // Fetch available food items from the database
  Future<void> _loadAvailableFoodItems() async {
    var fetchedData = await _databaseHelper.getFoodCalories();
    setState(() {
      // Update available food items and set 'isSelected' based on already selected items
      _availableFoodItems = fetchedData.map((item) => {
        ...item,
        'isSelected': _selectedFoodItems.any((selectedItem) => selectedItem['id'] == item['id']),
      }).toList();
    });
  }

  // Method to select a date using date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update selected date
      });
    }
  }

  // Calculate remaining calories based on target and selected food items
  int get _remainingCalories {
    int targetCalories = int.tryParse(_targetCaloriesController.text) ?? 0;
    int currentCalories = _selectedFoodItems.fold(0, (sum, el) => sum + (el['calories'] as int));
    return targetCalories - currentCalories; // Calculate remaining calories
  }

  // Toggle selection of a food item
  void _toggleFoodItem(Map<String, dynamic> item) {
    setState(() {
      item['isSelected'] = !item['isSelected']; // Toggle selected state
      if (item['isSelected']) {
        _selectedFoodItems.add(item); // Add selected item
      } else {
        _selectedFoodItems.removeWhere((el) => el['id'] == item['id']); // Remove deselected item
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _targetCaloriesController,
              decoration: const InputDecoration(
                labelText: 'Target Calories',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}), // Update UI on target calories change
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select date'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Remaining Calories: $_remainingCalories'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _availableFoodItems.length,
                itemBuilder: (context, index) {
                  final foodItem = _availableFoodItems[index];
                  return CheckboxListTile(
                    value: foodItem['isSelected'],
                    title: Text(foodItem['food']),
                    subtitle: Text('${foodItem['calories']} calories'),
                    onChanged: (bool? value) {
                      _toggleFoodItem(foodItem); // Toggle food item selection
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveUpdatedMealPlan, // Save updated meal plan on button press
        child: const Icon(Icons.save),
      ),
    );
  }

  // Save updated meal plan to the database
  void _saveUpdatedMealPlan() async {
    int remainingCalories = _remainingCalories;
    if (remainingCalories >= 0) {
      String foodItemsJson = jsonEncode(_selectedFoodItems); // Convert selected items to JSON
      await _databaseHelper.updateMealPlan(
        widget.mealPlan['id'],
        _selectedDate,
        int.parse(_targetCaloriesController.text),
        foodItemsJson,
      );
      Navigator.pop(context); // Go back after saving
    } else {
      // Show a snack bar if remaining calories are negative
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please adjust your meal plan.")),
      );
    }
  }

  @override
  void dispose() {
    _targetCaloriesController.dispose(); // Dispose of controller on widget disposal
    super.dispose();
  }
}
