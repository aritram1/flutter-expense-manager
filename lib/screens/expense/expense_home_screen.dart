import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import './expense_screen_0.dart';
import './expense_screen_1.dart';
import './expense_screen_2.dart';
import '../../widgets/finplan_app_home_screen_widget.dart';
import '../../utils/data_generator.dart';

class ExpenseHomeScreen extends StatelessWidget {
  ExpenseHomeScreen({super.key});
  static final dynamic log = Logger();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FinPlanAppHomeScreenWidget(
      title: 'Expense Home',
      caller: 'ExpenseHomeScreen',
      tabCount: 3,
      tabNames: const ['Expense', 'Transactions', 'A/c Overview'],
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: isLoading
              ? null
              : () async {
                  // Show dialog only if not loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return _buildSyncDialog();
                    },
                  );

                  // Simulate a syncing operation
                  await syncMessage();

                  // Close the dialog after syncMessage completes
                  Navigator.of(context).pop();
                },
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

  Widget _buildSyncDialog() {
    return const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Syncing...'),
        ],
      ),
    );
  }

  Future<void> syncMessage() async {
    Map<String, dynamic> response = await DataGenerator.syncMessages();
    Logger().d('Sync Message Response from Expense Home : $response');
  }
}
