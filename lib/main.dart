// main.dart

// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'util/data_generator.dart';
import './widget/tab_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyTabs(),
    );
  }
}

class MyTabs extends StatefulWidget {
  @override
  _MyTabsState createState() => _MyTabsState();
}

class _MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String title = 'Expense Manager';
  final Logger log = Logger();
  String messageSyncStatus = 'Default';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent dialog dismissal on tap outside
                builder: (BuildContext dialogContext) {
                  return const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16.0),
                          Text("Deleting Messages..."),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Perform the sync operation
              String result = await handleSMSAndTransactionsDelete();
              // log.d('Handle handleSMSAndTransactionsDelete Result => $result');

              // Close the loading dialog
              Navigator.of(context).pop();
            },
            tooltip: 'Delete All Messages and Transactions',
          ),
          
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent dialog dismissal on tap outside
                builder: (BuildContext dialogContext) {
                  return Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16.0),
                          Text('$messageSyncStatus...'),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Perform the sync operation
              String result = await handleSMSSync();
              // log.d('Handle Sync Message Result => $result');

              // Close the loading dialog
              Navigator.of(context).pop();
            },
            tooltip: 'Sync from Phone',
          ),
          // Add more action buttons if needed
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TabWidget(tabIndex: 0, title: 'Transactions'),
          TabWidget(tabIndex: 1, title: 'View Expenses'),
          TabWidget(tabIndex: 2, title: 'Bank Accounts'),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Transactions'),
          Tab(text: 'View Expenses'),
          Tab(text: 'Bank Accounts'),
        ],
      ),
    );
  }


  Future<String> handleSMSSync() async {
    log.d('Syncing SMS data...');
    
    // refresh the state
    // setState(() {
     messageSyncStatus = 'Syncing';
    // });
    
    Map<String, dynamic> response = await DataGenerator.deleteAllMessagesAndTransactions();
    log.d('Deleting completed.');

    // refresh the state
    
    // setState(() {
    //   messageSyncStatus = 'Critting';
    // });

    Map<String, dynamic> result = await DataGenerator.syncMessages();
    log.d('Syncing SMS data completed.');// Response : $result');
    return result.toString();
  }

  // Method to help mass deletion of SMS messages by calling the SF API `/api/sms/delete/*`
  Future<String> handleSMSAndTransactionsDelete() async {
    log.d('Deleting SMS data...');
    Map<String, dynamic> response = await DataGenerator.deleteAllMessagesAndTransactions();
    log.d('Deleting completed');//. encoded response is -> ${jsonEncode(response)}'); 
    return response.toString();
  }
}