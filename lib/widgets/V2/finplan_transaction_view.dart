// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class FinPlanTransactionView extends StatefulWidget {
  
  // Declare the class variables
  final String sms;
  final Function onCallBack;

  // Declare the constructor
  FinPlanTransactionView({
    super.key,
    required this.sms,
    required this.onCallBack
  });

  // Declare it's state class
  @override
  State<FinPlanTransactionView> createState() => _FinPlanTransactionViewState();
}

// State class for `FinPlanTransactionView`
class _FinPlanTransactionViewState extends State<FinPlanTransactionView> {

  late List<Map<String, dynamic>> data;

  @override void initState() {
    super.initState();
    data = [];
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
          children: [
            Text(widget.sms),
          ]
        ),
      ),
    );
  }
    
}

