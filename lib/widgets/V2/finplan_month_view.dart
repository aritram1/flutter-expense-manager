// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class FinPlanMonthView extends StatefulWidget {
  
  // Declare class variables
  String month;
  List<Map<String, dynamic>>? data;
  Function onCallBack;

  // Declare the constructor  
  FinPlanMonthView({
    super.key,
    required this.month,
    required this.onCallBack,
    this.data,
  });

  // Create its state instance
  State<FinPlanMonthView> createState() => _FinPlanMonthViewState();
}

// State class for `FinPlanMonthView`
class _FinPlanMonthViewState extends State<FinPlanMonthView> {

  late List<Map<String, dynamic>> data;

  @override void initState() {
    super.initState();
    data = widget.data ?? generateDefaultData();
  }

  @override
  Widget build(BuildContext context) {
    return 
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        width: 100,
        decoration:BoxDecoration(
          // color : Colors.red,
          gradient: LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade500, Colors.amber.shade600]),
          border: Border.all(
            color: Colors.red,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: []
        ),
      ),
    );
  }
  
  List<Map<String, dynamic>> generateDefaultData({int count = 2}) {
    List<Map<String, dynamic>> r = [];
    return r;
  }
    
}

