// Importing necessary packages and files
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_calories_calculator/view_meal_plan_page.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

// Creating a StatefulWidget for creating meal plans
class CreateMealPlanPage extends StatefulWidget {
  const CreateMealPlanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateMealPlanPageState createState() => _CreateMealPlanPageState();
}

// State class for the CreateMealPlanPage
class _CreateMealPlanPageState extends State<CreateMealPlanPage> {
  // Controllers, variables, and instances required for the page
  final _targetCaloriesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _selectedFoodItems = [];
  List<Map<String, dynamic>> _availableFoodItems = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  // Loading available food items from the database
  Future<void> _loadFoodItems() async {
    List<Map<String, dynamic>> fetchedData = await _databaseHelper.getFoodCalories();
    setState(() {
      _availableFoodItems = fetchedData.map((item) => {
        ...item,
        'isSelected': false,
      }).toList();
    });
  }

  // Function to select a date using a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Calculating remaining calories based on selected food items and target calories
  int get _remainingCalories {
    int targetCalories = int.tryParse(_targetCaloriesController.text) ?? 0;
    int currentCalories = _selectedFoodItems.fold(0, (sum, el) => sum + (el['calories'] as int));
    return targetCalories - currentCalories;
  }

  // Toggling selection of food items
  void _toggleFoodItem(Map<String, dynamic> item) {
    setState(() {
      item['isSelected'] = !item['isSelected'];
      if (item['isSelected']) {
        _selectedFoodItems.add(item);
      } else {
        _selectedFoodItems.removeWhere((el) => el['id'] == item['id']);
      }
    });
  }

  // Clearing all selections
  void _clearSelection() {
    setState(() {
      _selectedFoodItems.clear();
      for (var item in _availableFoodItems) {
        item['isSelected'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Building the UI for creating a meal plan
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text form field for target calories input
            TextFormField(
              controller: _targetCaloriesController,
              decoration: const InputDecoration(
                labelText: 'Target Calories',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
            ),
            // Displaying selected date and allowing date selection
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
            const SizedBox(height: 10),
            // Displaying remaining calories
            Text('Remaining Calories: $_remainingCalories'),
            const SizedBox(height: 20),
            // Displaying available food items with checkboxes
            Expanded(
              child: ListView.builder(
                itemCount: _availableFoodItems.length,
                itemBuilder: (context, index) {
                  final item = _availableFoodItems[index];
                  return CheckboxListTile(
                    value: item['isSelected'],
                    title: Text(item['food']),
                    subtitle: Text('${item['calories']} calories'),
                    onChanged: (bool? newValue) {
                      _toggleFoodItem(item);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Button to clear all selections
            ElevatedButton(
              onPressed: _clearSelection,
              child: const Text('Clear Selection'),
            ),
            const SizedBox(height: 20),
            // Button to save the meal plan
            ElevatedButton(
              onPressed:  () {
                _saveMealPlan(context);
              },
              child: const Text('Save Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to save the meal plan
  void _saveMealPlan(BuildContext context) async {
    if (_selectedFoodItems.isNotEmpty && _remainingCalories >= 0) {
      String foodItemsJson = jsonEncode(_selectedFoodItems);
      await _databaseHelper.addMealPlan(_selectedDate, int.parse(_targetCaloriesController.text), foodItemsJson);
      
      // Navigating to another page after saving the meal plan
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewMealPlanPage()),
      );
    } else {
      // Showing a snack bar message if the meal plan is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please adjust your meal plan.")),
      );
    }
  }

  @override
  void dispose() {
    _targetCaloriesController.dispose();
    super.dispose();
  }
}
