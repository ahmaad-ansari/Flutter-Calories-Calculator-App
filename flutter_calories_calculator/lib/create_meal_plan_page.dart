import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';


class CreateMealPlanPage extends StatefulWidget {
  const CreateMealPlanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateMealPlanPageState createState() => _CreateMealPlanPageState();
}

class _CreateMealPlanPageState extends State<CreateMealPlanPage> {
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

  Future<void> _loadFoodItems() async {
    List<Map<String, dynamic>> fetchedData = await _databaseHelper.getFoodCalories();
    setState(() {
      _availableFoodItems = fetchedData.map((item) => {
        ...item,
        'isSelected': false,
      }).toList();
    });
  }

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

  int get _remainingCalories {
    int targetCalories = int.tryParse(_targetCaloriesController.text) ?? 0;
    int currentCalories = _selectedFoodItems.fold(0, (sum, el) => sum + (el['calories'] as int));
    return targetCalories - currentCalories;
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meal Plan'),
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
              onChanged: (value) => setState(() {}),
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
            const SizedBox(height: 10),
            Text('Remaining Calories: $_remainingCalories'),
            const SizedBox(height: 20),
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
            ElevatedButton(
              onPressed: _clearSelection,
              child: const Text('Clear Selection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMealPlan,
              child: const Text('Save Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMealPlan() async {
    if (_selectedFoodItems.isNotEmpty && _remainingCalories >= 0) {
      String foodItemsJson = jsonEncode(_selectedFoodItems);
      await _databaseHelper.addMealPlan(_selectedDate, int.parse(_targetCaloriesController.text), foodItemsJson);
      // Navigator.pop(context); // Go back after saving
    } else {
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
