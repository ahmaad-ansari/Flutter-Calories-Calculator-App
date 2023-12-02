import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class UpdateMealPlanPage extends StatefulWidget {
  final Map<String, dynamic> mealPlan;

  const UpdateMealPlanPage({Key? key, required this.mealPlan}) : super(key: key);

  @override
  _UpdateMealPlanPageState createState() => _UpdateMealPlanPageState();
}

class _UpdateMealPlanPageState extends State<UpdateMealPlanPage> {
  late TextEditingController _targetCaloriesController;
  late DateTime _selectedDate;
  List<Map<String, dynamic>> _selectedFoodItems = [];
  List<Map<String, dynamic>> _availableFoodItems = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _targetCaloriesController = TextEditingController(text: widget.mealPlan['targetCalories'].toString());
    _selectedDate = DateTime.parse(widget.mealPlan['date']);
    
    var foodItemsJson = jsonDecode(widget.mealPlan['foodItems']);
    if (foodItemsJson is List) {
      _selectedFoodItems = List<Map<String, dynamic>>.from(foodItemsJson.map((item) => Map<String, dynamic>.from(item)));
    }

    _loadAvailableFoodItems();
  }

  Future<void> _loadAvailableFoodItems() async {
    var fetchedData = await _databaseHelper.getFoodCalories();
    setState(() {
      _availableFoodItems = fetchedData.map((item) => {
        ...item,
        'isSelected': _selectedFoodItems.any((selectedItem) => selectedItem['id'] == item['id']),
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
              onChanged: (_) => setState(() {}),
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
                      _toggleFoodItem(foodItem);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveUpdatedMealPlan,
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveUpdatedMealPlan() async {
    int remainingCalories = _remainingCalories;
    if (remainingCalories >= 0) {
      String foodItemsJson = jsonEncode(_selectedFoodItems);
      await _databaseHelper.updateMealPlan(
        widget.mealPlan['id'],
        _selectedDate,
        int.parse(_targetCaloriesController.text),
        foodItemsJson,
      );
      Navigator.pop(context); // Go back after saving
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
