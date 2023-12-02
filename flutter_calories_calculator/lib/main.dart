// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:flutter_calories_calculator/database_helper.dart'; // Importing database helper
import 'create_meal_plan_page.dart'; // Importing other app screens
import 'food_calorie_pair_page.dart';
import 'view_meal_plan_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import FFI sqflite for desktop

// Main function for the Flutter application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter Widgets

  // Initialize sqflite for desktop platforms
  sqfliteFfiInit();
  
  // Set the database factory to FFI for desktop
  databaseFactory = databaseFactoryFfi;

  runApp(const CalorieCalculatorApp()); // Run the main app widget
}

// Root widget for the Flutter application
class CalorieCalculatorApp extends StatelessWidget {
  const CalorieCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Calculator',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(), // Set the home screen as MainScreen
    );
  }
}

// Main screen widget managing the bottom navigation bar and screens
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Index to track current screen
  final List<Widget> _screens = [
    const FoodCaloriePairPage(), // List of screens to display in the bottom navigation bar
    const CreateMealPlanPage(),
    const ViewMealPlanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'), // App bar title
      ),
      body: _screens[_currentIndex], // Display the current screen
      bottomNavigationBar: BottomNavigationBar(
        // Bottom navigation bar to switch between screens
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the index on tap to change the screen
          });
        },
        items: const [
          // Define items for each screen in the bottom navigation bar
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
