import 'dart:convert';
import 'package:flutter/material.dart';
import 'update_meal_plan_page.dart';
import 'database_helper.dart';

class ViewMealPlanPage extends StatefulWidget {
  const ViewMealPlanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ViewMealPlanPageState createState() => _ViewMealPlanPageState();
}

class _ViewMealPlanPageState extends State<ViewMealPlanPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late List<Map<String, dynamic>> _mealPlans;

  @override
  void initState() {
    super.initState();
    _mealPlans = []; // Initialize _mealPlans in initState
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    List<Map<String, dynamic>> fetchedData = await _databaseHelper.getMealPlans();
    setState(() {
      _mealPlans = fetchedData;
    });
  }

  void _deleteMealPlan(int id) async {
    await _databaseHelper.deleteMealPlan(id);
    _loadMealPlans();
  }

  void _navigateToUpdateMealPlanPage(Map<String, dynamic> mealPlan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateMealPlanPage(mealPlan: mealPlan),
      ),
    ).then((_) {
      _loadMealPlans(); // Refresh the list after updating
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Meal Plans'),
      ),
      body: ListView.builder(
        itemCount: _mealPlans.length,
        itemBuilder: (context, index) {
          final mealPlan = _mealPlans[index];
          final foodItems = jsonDecode(mealPlan['foodItems']) as List;
          String formattedDate = mealPlan['date'] != null ? DateTime.parse(mealPlan['date']).toString().split(' ')[0] : '';
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Meal Plan for $formattedDate'),
              subtitle: Text('Total Calories: ${mealPlan['targetCalories']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToUpdateMealPlanPage(mealPlan),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteMealPlan(mealPlan['id']),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Food Items on $formattedDate'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: foodItems.map<Widget>((item) => Text(item['food'])).toList(),
                        ),
                      ),
                      actions: <Widget>[
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
              },
            ),
          );
        },
      ),
    );
  }
}
