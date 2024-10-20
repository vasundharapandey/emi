import 'package:flutter/material.dart';
import 'package:credemi/screens/stack_view_app.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.question_mark, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: StackedExpandableWidgets(),
    );
  }
}