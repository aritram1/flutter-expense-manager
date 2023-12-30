import 'package:flutter/material.dart';
import './expense_screen_0.dart';
import './expense_screen_1.dart';
import './expense_screen_2.dart';
import '../../widgets/finplan_app_home_screen_widget.dart';
// import '../../utils/data_generator.dart';
// import 'package:logger/logger.dart';


class ExpenseHomeScreen extends StatelessWidget {
  const ExpenseHomeScreen({Key? key});
  
  @override
  Widget build(BuildContext context) {
    return FinPlanAppHomeScreenWidget(
      title: 'Expense Home',
      caller: 'ExpenseHomeScreen',
      tabCount: 3, 
      tabNames: const ['Expense', 'Transactions', 'Bank Accounts'], 
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {},
        ),
      ],
      tabBarViews: [
        ExpenseScreen0(),
        ExpenseScreen1(),
        ExpenseScreen2(),
      ],
    );
  }
}