// ignore_for_file: use_key_in_widget_constructors, avoid_print, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import './widget/table_widget.dart';

class TabData extends StatelessWidget {
  final int tabIndex;

  TabData({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement tab-specific floating button logic here
          print('Floating button pressed on Tab $tabIndex');
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tab $tabIndex'),
            TableData(tabIndex: tabIndex),
          ],
        ),
      ),
    );
  }
}
