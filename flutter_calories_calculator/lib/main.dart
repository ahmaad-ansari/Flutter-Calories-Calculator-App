import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'create_meal_plan_page.dart';
import 'food_calorie_pair_page.dart';
import 'view_meal_plan_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms
  sqfliteFfiInit();
  
  // Set the database factory to FFI
  databaseFactory = databaseFactoryFfi;

  runApp(const CalorieCalculatorApp());
}


class CalorieCalculatorApp extends StatelessWidget {
  const CalorieCalculatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Calculator',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const FoodCaloriePairPage(),
    const CreateMealPlanPage(),
    const ViewMealPlanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Food Calories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create Meal Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'View Meal Plans',
          ),
        ],
      ),
    );
  }
}
