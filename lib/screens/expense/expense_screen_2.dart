import 'package:ExpenseManager/screens/expense/expense_data_generator.dart';
import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ExpenseScreen2 extends StatelessWidget {
  static final Logger log = Logger();

  ExpenseScreen2({super.key});

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from ExpenseScreen2 => $result');
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ExpenseDataGenerator.generateDataForExpenseScreen2(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } 
        else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading data ExpenseScreen2! ${snapshot.error.toString()}'),
          );
        }
        else {
          return FinPlanTableWidget(
            key: key,
            headerNames: const ['Name', 'Balance', 'Last Updated'],
            noRecordFoundMessage: 'Nothing to approve',
            caller: 'ExpenseScreen2',
            columnWidths: const [0.2, 0.25, 0.35],
            data: snapshot.data!,
            onLoadComplete: onLoadComplete,
            defaultSortcolumnName: 'Last Updated', // 2 meaning the Date column
            showSelectionBoxes : false
          );
        }
      },
    );
  }
}