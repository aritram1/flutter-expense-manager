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
      future: DataGenerator.generateTab1Data(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading data here! ${snapshot.error.toString()}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        } else {
          log.d('Snapshot Data : ${snapshot.data!}');
          return FinPlanTableWidget(
            key: key,
            headerNames: const ['Paid To', 'Amount', 'Date'],
            noRecordFoundMessage: 'Nothing to approve',
            caller: 'ExpenseScreen0',
            columnWidths: const [0.3, 0.2, 0.2],
            data: snapshot.data!,
            onLoadComplete: onLoadComplete,
            defaultSortcolumnName: 'Date', // 2 meaning the Date column
          );
        }
      },
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //     future: DataGenerator.generateTab1Data(),
  //     builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       } else if (snapshot.hasError) {
  //         return Center(
  //           child: Text('Error loading data here! ${snapshot.error.toString()}'),
  //         );
  //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //         return const Center(
  //           child: Text('No data available'),
  //         );
  //       } else {
  //         return FinPlanTableWidget(
  //           key: key,
  //           headerNames: const ['Paid To', 'Amount', 'Date'],
  //           noRecordFoundMessage: 'Nothing to approve',
  //           caller: 'ExpenseScreen0',
  //           columnWidths: const [0.3, 0.2, 0.2],
  //           data: snapshot.data!,
  //           onLoadComplete: onLoadComplete,
  //           defaultSortcolumnName: 'Date', // 2 meaning the Date column
  //         );
  //       }
  //     },
  //   );
  // }


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
     
