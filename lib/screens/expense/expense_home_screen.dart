import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import './expense_screen_0.dart';
import './expense_screen_1.dart';
import './expense_screen_2.dart';
import '../../widgets/finplan_app_home_screen_widget.dart';
import '../../utils/data_generator.dart';

class ExpenseHomeScreen extends StatefulWidget {
  
  const ExpenseHomeScreen({super.key});
  
  @override
  ExpenseHomeScreenState createState() => ExpenseHomeScreenState();
}

class ExpenseHomeScreenState extends State<ExpenseHomeScreen>{

  static final dynamic log = Logger();
  
  static bool isLoading = false;

  static String action = ''; // This will be name of the current running action that are available to the page (like sync, delete etc)

  @override
  Widget build(BuildContext context) {
    return 
      isLoading 
      ? AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('$action In Progress'),
            ],
          ),
        )
      : FinPlanAppHomeScreenWidget(
        title: 'Expense Home',
        caller: 'ExpenseHomeScreen',
        tabCount: 3,
        tabNames: const ['Expense', 'Transactions', 'A/c Overview'],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
                BuildContext currentContext = context;
                // Get an alert dialog as confirmation box
                bool shouldProceed = await showConfirmationBox(currentContext, 'Sync');
                if(shouldProceed){
                  await syncMessage(); // Call the method now
                }
              },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
                BuildContext currentContext = context;
                // Get an alert dialog as confirmation box
                bool shouldProceed = await showConfirmationBox(currentContext, 'Delete');
                if(shouldProceed){
                  await deleteMessageAndTransactions(); // Call the method now
                }
              },                
          ),
        ],
        tabBarViews: [
          const ExpenseScreen0(),
          const ExpenseScreen1(),
          ExpenseScreen2(),
        ],
      );
    }

  // Call the sync method
  Future<void> syncMessage() async {
    
    setState((){
      action = 'Sync';
      isLoading = true;
    });
    
    Map<String, dynamic> response = await DataGenerator.syncMessages();
    
    setState((){
      isLoading = false;
    });
    
    Logger().d('Sync Message Response from Expense Home : $response');
  }

  // Call the delete method
  Future<void> deleteMessageAndTransactions() async {

    setState((){
      action = 'Delete';
      isLoading = true;
    });

    String response = await DataGenerator.hardDeleteMessagesAndTransactions();
    
    setState((){
      isLoading = false;
    });

    Logger().d('deleteMessageAndTransactions Message Response from Expense Home : $response');
  }

  // A confirmation box to show if its ok to proceed with sync and delete operation
  static Future<dynamic> showConfirmationBox(BuildContext context, String opType){
    String title = 'Please confirm'; 
    String content =  (opType == 'Sync') ? 'This will delete and resync all. Proceed?' : 'This will delete all. Proceed?' ;
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
