import 'package:flutter/material.dart';
// import '../../utils/data_generator_local.dart';
import '../../utils/data_generator.dart';
import '../../widgets/finplan_table_widget.dart';
import 'package:logger/logger.dart';

class ExpenseScreen0 extends StatelessWidget {
  static final Logger log = Logger();

  ExpenseScreen0({super.key});

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from ExpenseScreen0 => $result');
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DataGenerator.generateDataForExpenseScreen0(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        else if (snapshot.hasError) {
          log.e('Error loading data => ${snapshot.error.toString()}');
          return Center(
            child: Text('Error loading data => ${snapshot.error.toString()}'),
          );
        }
        else {
          return FinPlanTableWidget(
            key: key,
            headerNames: const ['Paid To', 'Amount', 'Date'],
            noRecordFoundMessage: 'Nothing to approve',
            caller: 'ExpenseScreen0',
            columnWidths: const [0.3, 0.2, 0.2],
            data: snapshot.data!,
            onLoadComplete: onLoadComplete,
            defaultSortcolumnName: 'Date',
          );
        }
      },
    );
  }
}