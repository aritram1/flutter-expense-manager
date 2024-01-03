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
              BuildContext currentContext = context;
              bool shouldProceed = await showConfirmationBox(currentContext, 'Sync');// Show dialog only if not loading
              if(shouldProceed){
                await showDialog(
                  context: currentContext,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return _buildSyncDialog('Syncing...');
                  },
                );

                // Simulate a syncing operation
                await syncMessage();

                // Close the dialog after syncMessage completes
                Navigator.of(currentContext).pop();
              }
            },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: isLoading
              ? null
              : () async {
                BuildContext currentContext = context;
                bool shouldProceed = await showConfirmationBox(currentContext, 'Delete');// Show dialog only if not loading
                if(shouldProceed){
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return _buildSyncDialog('Deleting...');
                    },
                  );

                  // Simulate a syncing operation
                  await deleteMessageAndTransactions();

                  // Close the dialog after syncMessage completes
                  Navigator.of(context).pop();
                }
              },
        ),
      ],
      tabBarViews: [
        ExpenseScreen0(),
        ExpenseScreen1(),
        ExpenseScreen2(),
      ],
    );
  }

  Widget _buildSyncDialog(String opName) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(opName),
        ],
      ),
    );
  }

  Future<void> syncMessage() async {
    Map<String, dynamic> response = await DataGenerator.syncMessages();
    Logger().d('Sync Message Response from Expense Home : $response');
  }

  Future<void> deleteMessageAndTransactions() async {
    String response = await DataGenerator.hardDeleteMessagesAndTransactions();
    Logger().d('deleteMessageAndTransactions Message Response from Expense Home : $response');
  }


  static Future<dynamic> showConfirmationBox(BuildContext context, String opType){
    String title = 'Please confirm'; 
    String content =  (opType == 'Sync') ? 'Do you want to sync?' : 'Do you want to delete?' ;
    String choiceYes = 'Yes';
    String choiceNo = 'No';
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User clicked No
              },
              child: Text(choiceNo),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User clicked Yes
              },
              child: Text(choiceYes),
            ),
          ],
        );
      },
    );
  }
  
}
