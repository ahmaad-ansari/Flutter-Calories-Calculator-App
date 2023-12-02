import 'dart:convert';
import 'package:flutter/material.dart';
import 'update_meal_plan_page.dart';
import 'database_helper.dart';

class ViewMealPlanPage extends StatefulWidget {
  const ViewMealPlanPage({Key? key}) : super(key: key);

  @override
  _ViewMealPlanPageState createState() => _ViewMealPlanPageState();
}

class _ViewMealPlanPageState extends State<ViewMealPlanPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late List<Map<String, dynamic>> _mealPlans;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _mealPlans = [];
    _loadMealPlans();
    _searchController = TextEditingController();
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
      _loadMealPlans();
    });
  }

  void _filterByDate(String query) {
    List<Map<String, dynamic>> filteredPlans = _mealPlans.where((plan) {
      String formattedDate = plan['date'] != null ? DateTime.parse(plan['date']).toString().split(' ')[0] : '';
      return formattedDate.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _mealPlans = filteredPlans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Meal Plans'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MealPlanSearch(_mealPlans, _filterByDate),
              );
            },
          ),
        ],
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

class MealPlanSearch extends SearchDelegate<String> {
  final List<Map<String, dynamic>> mealPlans;
  final Function(String) filterCallback;

  MealPlanSearch(this.mealPlans, this.filterCallback);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(); // Implement if needed
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = query.isEmpty
        ? mealPlans // Show all meal plans initially if the query is empty
        : mealPlans.where((plan) {
            String formattedDate =
                plan['date'] != null ? DateTime.parse(plan['date']).toString().split(' ')[0] : '';
            return formattedDate.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final mealPlan = suggestions[index];
        final foodItems = jsonDecode(mealPlan['foodItems']) as List;

        String formattedDate =
            mealPlan['date'] != null ? DateTime.parse(mealPlan['date']).toString().split(' ')[0] : '';

        return ListTile(
          title: Text('Meal Plan for $formattedDate'),
          subtitle: Text('Total Calories: ${mealPlan['targetCalories']}'),
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
        );
      },
    );
  }

}
