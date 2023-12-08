// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'widget/tab_data.dart';
import 'package:logger/logger.dart';
import 'util/message_util.dart';
import 'util/salesforce_util.dart';

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

  void handleSMSSync() async {
    log.d('Syncing SMS data...');
    List<SmsMessage> messages = await MessageUtil.getMessages();
    List<Map<String, dynamic>> processedMessages = await MessageUtil.convert(messages);
    String result = await SalesforceUtil.saveToSalesForce('FinPlan__SMS_Message__c', processedMessages);
    log.d('RESULT IS->$result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: handleSMSSync,
            tooltip: 'Sync from Phone',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TabData(tabIndex: 0, title: 'Credit/Debit'),
          TabData(tabIndex: 1, title: 'Investments', isCardLayout: true),
          TabData(tabIndex: 2, title: 'Another Category'),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Credit/Debit'),
          Tab(text: 'Investments'),
          Tab(text: 'Another'),
        ],
      ),
    );
  }
}
