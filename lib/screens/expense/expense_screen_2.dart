import 'package:flutter/material.dart';
// import '../../utils/data_generator_local.dart';
import '../../utils/data_generator.dart';
import '../../widgets/finplan_table_widget.dart';
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
      future: DataGenerator.generateTab3Data(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading data ExpenseScreen2! ${snapshot.error.toString()}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available in ExpenseScreen2'),
          );
        } else {
          return FinPlanTableWidget(
            key: key,
            headerNames: const ['Name', 'Balance', 'Date'],
            noRecordFoundMessage: 'Nothing to approve',
            caller: 'ExpenseScreen2',
            columnWidths: const [0.2, 0.3, 0.2],
            data: snapshot.data!,
            onLoadComplete: onLoadComplete,
            defaultSortcolumnName: 'Date', // 2 meaning the Date column
            showSelectionBoxes : false
          );
        }
      },
    );
  }
}