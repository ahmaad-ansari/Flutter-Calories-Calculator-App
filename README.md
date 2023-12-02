# FlutterCaloriesCalculator App

## Overview

FlutterCaloriesCalculator is a mobile application developed using Flutter and Dart. The app allows users to manage their daily calorie intake by selecting food items and planning their meals.

## Features

- **Database Management**: Stores preferred food items and calorie pairs.
- **Meal Planning**: Allows users to select a target calorie count per day, a date, and food items not to exceed the target calories.
- **Data Persistence**: Saves selected food items (meal plan) into the database with a date.
- **Query Functionality**: Displays meal plans for a specific date from the database.
- **CRUD Operations**: Supports adding, deleting, and updating entries.

## Screenshots

### Home Screen
![Alt text](<Food Calories View.png>)
![Alt text](<Food Calories Add.png>)
![Alt text](<Food Calories Add Error.png>)
![Alt text](<Create Meal Plan.png>) 
![Alt text](<Create Meal Plan Error.png>)
![Alt text](<View Meal Plans.png>) 
![Alt text](<View Meal Plan Specific.png>)
![Alt text](<Update Meal Plan.png>)

## Installation

To run the application, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/ahmaad-ansari/SOFE4640U-Assignment-3
   ```

2. Navigate to the project directory and install dependencies:

   ```bash
   cd flutter_calories_calculator
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```