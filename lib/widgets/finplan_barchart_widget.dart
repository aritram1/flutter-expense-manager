// ignore_for_file: prefer_const_constructors

import 'package:ExpenseManager/utils/data_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../utils/finplan_exception.dart';
import 'package:fl_chart/fl_chart.dart';

class FinPlanBarChartWidget extends StatefulWidget {
  
  final dynamic data;
  final Function(String) onComplete;
  
  const FinPlanBarChartWidget({
    Key? key,
    required this.data,
    required this.onComplete,
  }) : super(key: key);

  @override
  FinPlanBarChartWidgetState createState() => FinPlanBarChartWidgetState();
}

class FinPlanBarChartWidgetState extends State<FinPlanBarChartWidget> {

  @override
  void initState() {

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello World!');
  }

}