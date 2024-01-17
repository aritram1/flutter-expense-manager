
import 'package:ExpenseManager/utils/local/data_generator_local.dart';
import 'package:ExpenseManager/widgets/finplan_table_widget.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

class HomeScreen0 extends StatelessWidget {
  static final Logger log = Logger();

  HomeScreen0({super.key});

  dynamic Function(String) onLoadComplete = (result) {
    log.d('Table loaded Result from HomeScreen0 => $result');
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DataGeneratorLocal.generateMockDataForHome(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading data in HomeScreen0'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available in HomeScreen0'),
          );
        } else {
          return FinPlanTableWidget(
            key: key,
            headerNames: const ['Paid To', 'Amount', 'Date'],
            noRecordFoundMessage: 'Nothing to approve',
            caller: 'HomeScreen0',
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

//   case 0:
//     message = 'Nothing to approve';
//     break;
//   case 1:
//     message = 'No transactions are available between the dates';
//     break;
//   case 2:
//     message = 'No bank accounts are available to show';
//     break;
//   // Add more cases if needed
//   default:
//     message = 'Default Message : No data found';