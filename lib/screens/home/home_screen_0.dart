import 'package:flutter/material.dart';
import '../../widgets/finplan_table_widget.dart';
import 'package:logger/logger.dart';

class HomeScreen0 extends StatelessWidget {
  static final Logger log = Logger();

  HomeScreen0({super.key});

  final List<Map<String, dynamic>> data = []; //generateMockDataForExpense();

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from HomeScreen0=> $result');
  };

  @override
  Widget build(BuildContext context) {
    return FinPlanTableWidget(
      data: data,
      key: key,
      headerNames: const ['Paid To', 'Amount', 'Date', 'Id'],
      onLoadComplete: onLoadComplete,
      caller: 'HomeScreen0',
      noRecordFoundMessage: 'Nothing to Approve at the moment!',
      columnWidths: const [0.2, 0.3, 0.4],
      defaultSortcolumnName: 'Date', // 2 means date column
    );
  }
}
