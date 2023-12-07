// main.dart

import 'package:flutter/material.dart';
import 'tab_data.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Manager'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TabData(tabIndex: 0, title: 'Credit/Debit'),
          TabData(tabIndex: 1, title: 'Investments'),
          TabData(tabIndex: 2, title: 'Another Category'),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'Credit/Debit'),
          Tab(text: 'Investments'),
          Tab(text: 'Another'),
        ],
      ),
    );
  }
}
