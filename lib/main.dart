import 'package:flutter/material.dart';
import 'screens/stack_view_app.dart';
import 'screens/HomePage.dart';
void main() {
  runApp(MaterialApp(
    title: 'Loan Stack Views',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: MyHomePage(),
  ));
}