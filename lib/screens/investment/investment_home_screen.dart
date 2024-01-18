import 'package:ExpenseManager/screens/investment/investment_screen_0.dart';
import 'package:ExpenseManager/screens/investment/investment_screen_1.dart';
import 'package:ExpenseManager/utils/data_generator.dart';
import 'package:ExpenseManager/widgets/finplan_add_new_investment_widget.dart';
import 'package:ExpenseManager/widgets/finplan_app_home_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class InvestmentHomeScreen extends StatefulWidget {
  
  const InvestmentHomeScreen({super.key});
  
  @override
  InvestmentHomeScreenState createState() => InvestmentHomeScreenState();
}

class InvestmentHomeScreenState extends State<InvestmentHomeScreen>{

  static final dynamic log = Logger();
  
  static bool isLoading = false;

  static String action = ''; // This will be name of the current running action that are available to the page (like sync, delete etc)

  @override
  Widget build(BuildContext context) {
    return 
      // show alert dialog during loading
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
      // once loading is completed, show the actual home screen
      : FinPlanAppHomeScreenWidget(
          title: 'Investment Home', 
          caller: 'InvestmentHomeScreen',
          tabCount: 2, 
          tabNames: const ['Investments', 'Detail'], 
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () async {
                // await Future.delayed(const Duration(milliseconds: 100));
                BuildContext currentContext = context;
                await showAddNewInvestmentWidget(currentContext);
              },
            ),
            IconButton(
              icon: const Icon(Icons.sync_outlined),
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
            const InvestmentScreen0(),
            InvestmentScreen1(),
          ],
      );
    }

  // To show the widget for adding new expenses
  static Future<dynamic> showAddNewInvestmentWidget(BuildContext context) async {
    // log.d('Inside showAddNewInvestmentWidget async!');
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return FinPlanAddNewInvestmentWidget(
          onSave: (amount, paidTo, investmentId, details, selectedDate) async {
            Map<String, dynamic> response = await DataGenerator.insertNewInvestmentToSalesforce(amount, paidTo, investmentId, details, selectedDate);
            log.d('New investment created : ${response.toString()}');
            Navigator.pop(context); // Close the dialog after saving
          },
        );
      },
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
    
    Logger().d('Message synced : ${response['data'].length}');
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
    String choiceYes = 'Yes';
    String choiceNo = 'No';
    String content =  (opType == 'Sync') 
                            ? 'This will delete existing messages and recreate them. Proceed?' 
                            : 'This will delete all messages and transactions. Proceed?' ;
    
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
