import 'package:flutter/material.dart';
import '../../widgets/finplan_table_widget.dart';
// import '../util/data_generator.dart';
import 'package:logger/logger.dart';

class ExpenseScreen2 extends StatelessWidget {
  ExpenseScreen2({Key? key});
  final Logger log = Logger();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Expense Content 2'),
    );
  }
}
