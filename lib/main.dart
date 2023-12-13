// main.dart

// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import './util/data_generator.dart';
import './util/message_util.dart';
import './util/salesforce_util.dart';
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
                          Text("Deleting..."),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Perform the sync operation
              String result = await handleSMSDelete();
              log.d('Handle Delete Message Result => $result');

              // Close the loading dialog
              Navigator.of(context).pop();
            },
            tooltip: 'Delete All Messages',
          ),
          
          IconButton(
            icon: const Icon(Icons.sync),
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
                          Text("Syncing..."),
                        ],
                      ),
                    ),
                  );
                },
              );

              // Perform the sync operation
              String result = await handleSMSSync();
              log.d('Handle Sync Message Result => $result');

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
          TabData(tabIndex: 0, title: 'Transactions'),
          TabData(tabIndex: 1, title: 'View Expenses'),
          TabData(tabIndex: 2, title: 'Investments'),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Transactions'),
          Tab(text: 'View Expenses'),
          Tab(text: 'Investments'),
        ],
      ),
    );
  }

  Future<String> handleSMSSync() async {
    String resultString = '';
    // Your logic for handling SMS sync goes here
    log.d('Syncing SMS data...');
    // List<SmsMessage> messages = await MessageUtil.getMessages(count : 200); // Change this while debugging
    List<SmsMessage> messages = await MessageUtil.getMessages(); // Change this while debugging
    List<Map<String, dynamic>> processedMessages = await MessageUtil.convert(messages);
    String transactionsDeleteResponse = await SalesforceUtil.callTransactionsDeleteAPI('FinPlan__Bank_Transaction__c | FinPlan__Investment_Transaction__c'); //TBD just a placeholder
    log.d('transactionsDeleteResponse response IS->$transactionsDeleteResponse');
    String response = await SalesforceUtil.saveToSalesForce('FinPlan__SMS_Message__c', processedMessages);
    log.d('handleSMSSync response IS->$response');

    try{
      Map<String, dynamic> resultMap = jsonDecode(response);
      if (resultMap['hasErrors'] == true && resultMap['results'].isNotEmpty) {
        resultString = resultMap['results'][0]['errors'][0]['message'];
      } else {
        resultString = 'Success';
      }
    }
    catch(error){
      resultString = error.toString();
    }
    return resultString;
  }

// Method to help mass deletion of SMS messages by calling the SF API `/api/sms/delete/*`
Future<String> handleSMSDelete() async {
  log.d('Deleting SMS data...');
  String response = await DataGenerator.deleteAllMessages('');
  log.d('Delete response IS->$response'); 
  return response;
}
}
